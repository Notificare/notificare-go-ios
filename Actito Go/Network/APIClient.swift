//
//  APIClient.swift
//  Actito Go
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
        
        return try await AF.request(url)
            .validate()
            .serializingDecodable()
            .value
    }
    
    static func createEnrollment(programId: String, payload: CreateEnrollmentPayload) async throws -> CreateEnrollmentResponse {
        let url = baseUrl
            .appendingPathComponent("loyalty")
            .appendingPathComponent("profile")
            .appendingPathComponent("enrollment")
            .appendingPathComponent(programId)
        
        var headers: HTTPHeaders = []
        
        if let configuration = Preferences.standard.appConfiguration {
            headers.add(.authorization(username: configuration.applicationKey, password: configuration.applicationSecret))
        }
        
        return try await AF.request(url, method: .post, parameters: payload, encoder: .json, headers: headers)
            .validate()
            .serializingDecodable()
            .value
    }
}
