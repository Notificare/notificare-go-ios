//
//  APIClient+Responses.swift
//  Actito Go
//
//  Created by Helder Pinhal on 05/04/2022.
//

import Foundation

extension APIClient {
    struct GetConfigurationResponse: Decodable {
        let demo: Demo
        
        struct Demo: Decodable {
            let applicationKey: String
            let applicationSecret: String
            let loyaltyProgram: String?
        }
    }
    
    struct CreateEnrollmentResponse: Decodable {
        let pass: Pass
        let saveLinks: SaveLinks
        
        struct Pass: Decodable {
            let serial: String
            let barcode: String
        }
        
        struct SaveLinks: Decodable {
            let appleWallet: String
            let googlePay: String
        }
    }
}
