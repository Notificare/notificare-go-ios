//
//  AppScannerViewModel.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 05/04/2022.
//

import Foundation
import CodeScanner

@MainActor class AppScannerViewModel: ObservableObject {
    @Published var isScanning = false
    @Published var processScanState = ProcessScanState.idle
    
    func handleScan(_ result: Result<ScanResult, ScanError>) {
        isScanning = false
        
        switch result {
        case let .success(result):
            guard let code = extractScanCode(from: result.string) else {
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
                        applicationSecret: response.demo.applicationSecret
                    )
                    
                    processScanState = .success
                    
                    ContentRouter.main.route = .splash
                } catch {
                    print("Failed to fetch the remote configuration. \(error)")
                    processScanState = .failure
                }
            }
        case let .failure(error):
            print("Failed to scan the QR code. \(error)")
            processScanState = .failure
        }
    }
    
    
    
    private func extractScanCode(from str: String) -> String? {
        guard let url = URL(string: str) else {
            // Unable to parse the URL.
            return nil
        }
        
        guard url.scheme == "https",
              let hostComponents = url.host?.components(separatedBy: "."),
              hostComponents.count == 4,
              hostComponents[1] == "demo",
              hostComponents[2] == "notificare",
              hostComponents[3] == "com"
        else {
            // Invalid URL format.
            return nil
        }
        
        return hostComponents[0]
    }
    
    
    enum ProcessScanState {
        case idle
        case processing
        case success
        case failure
    }
}
