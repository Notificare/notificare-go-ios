//
//  APIClient+Payloads.swift
//  Notificare Go
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
        }
        
        struct Field: Encodable {
            let key: String
            let value: String
        }
    }
}
