//
//  AppScannerViewModel.swift
//  Actito Go
//
//  Created by Helder Pinhal on 05/04/2022.
//

import Foundation
import CodeScanner
import OSLog

@MainActor class AppScannerViewModel: ObservableObject {
    @Published var isScanning = false
    @Published var processScanState = ProcessScanState.idle
    
    func handleScan(_ result: Result<ScanResult, ScanError>) {
        isScanning = false
        
        switch result {
        case let .success(result):
            guard let url = URL(string: result.string), let code = extractCodeParameter(from: url) else {
                processScanState = .failure
                return
            }
            
            processScanState = .processing
            
            Task {
                do {
                    let response = try await APIClient.getConfiguration(code: code)
                    
                    // Persist the configuration.
                    Preferences.standard.appConfiguration = AppConfiguration(
                        applicationKey: response.demo.applicationKey,
                        applicationSecret: response.demo.applicationSecret,
                        loyaltyProgramId: response.demo.loyaltyProgram
                    )
                    
                    processScanState = .success
                    
                    ContentRouter.main.route = .splash
                } catch {
                    Logger.main.error("Failed to fetch the remote configuration. \(error.localizedDescription)")
                    processScanState = .failure
                }
            }
        case let .failure(error):
            Logger.main.error("Failed to scan the QR code. \(error.localizedDescription)")
            processScanState = .failure
        }
    }
    
    enum ProcessScanState {
        case idle
        case processing
        case success
        case failure
    }
}
