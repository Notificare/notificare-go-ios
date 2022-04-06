//
//  APIClient.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 05/04/2022.
//

import Foundation
import Alamofire

enum APIClient {
    private static let baseUrl = URL(string: "https://push.notifica.re")!
    
    static func getConfiguration(code: String) async throws -> GetConfigurationResponse {
        let url = baseUrl
            .appendingPathComponent("download")
            .appendingPathComponent("demo")
            .appendingPathComponent("code")
            .appendingPathComponent(code)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return try await AF.request(url)
            .validate()
            .serializingDecodable()
            .value
    }
}
