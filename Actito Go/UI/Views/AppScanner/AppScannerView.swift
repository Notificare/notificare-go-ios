//
//  AppScannerView.swift
//  Actito Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import SwiftUI
import CodeScanner

struct AppScannerView: View {
    @StateObject private var viewModel: AppScannerViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: AppScannerViewModel())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    LottieView(name: "animation-qr-code-scanner", loopMode: .loop)
                        .scaledToFit()
                        .frame(height: 256)
                        .padding(.top, 0)
                    
                    Text(verbatim: String(localized: "app_scanner_title"))
                        .font(.title)
                        .padding(.top)
                    
                    Text(verbatim: String(localized: "app_scanner_message"))
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .padding(.top)

                    Button {
                        viewModel.isScanning = true
                        viewModel.processScanState = .idle
                    } label: {
                        Text(String(localized: "app_scanner_scan_button"))
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .adaptivePrimaryButton()
                    .disabled(viewModel.isScanning || viewModel.processScanState == .processing)
                    .padding(.top, 32)
                    
                    if viewModel.processScanState == .failure {
                        AlertBlock(type: .error, title: String(localized: "app_scanner_scan_error_title")) {
                            Text(String(localized: "app_scanner_scan_error_message"))
                        }
                        .padding(.top)
                    }
                    
                    if viewModel.processScanState == .processing {
                        ProgressView()
                            .padding(.top)
                    }
                }
                .padding()
                .sheet(isPresented: $viewModel.isScanning) {
                    CodeScannerView(codeTypes: [.qr]) { result in
                        viewModel.handleScan(result)
                    }
                    .ignoresSafeArea()
                }
            }
            .navigationTitle("Scanner")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AppScannerView_Previews: PreviewProvider {
    static var previews: some View {
        AppScannerView()
    }
}
