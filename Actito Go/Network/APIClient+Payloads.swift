//
//  APIClient+Payloads.swift
//  Actito Go
//
//  Created by Helder Pinhal on 09/06/2022.
//

import Foundation

extension APIClient {
    struct CreateEnrollmentPayload: Encodable {
        let userId: String
        let memberId: String
        let fields: [Field]
        
        private enum CodingKeys: String, CodingKey {
            case userId = "userID"
            case memberId
            case fields
        }
        
        struct Field: Encodable {
            let key: String
            let value: String
        }
    }
}
