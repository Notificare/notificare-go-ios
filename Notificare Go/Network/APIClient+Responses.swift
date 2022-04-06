//
//  APIClient+Responses.swift
//  Notificare Go
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
            // let loyaltyProgram: String
        }
    }
}
