//
//  CurrentUser.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 10/03/2022.
//

import AuthenticationServices
import CommonCrypto
import Foundation

struct CurrentUser: Codable {
    private static let decoder = JSONDecoder()
    
    let id: String
    let name: String?
    let email: String?
}

extension CurrentUser {
    init(credential: ASAuthorizationAppleIDCredential) {
        self.id = credential.user
        self.name = credential.name
        self.email = credential.email
    }
}

extension CurrentUser {
    var gravatarUrl: URL? {
        let hash = md5(email?.lowercased() ?? id)
        return URL(string: "https://gravatar.com/avatar/\(hash)?s=400&d=retro")
    }
    
    private func md5(_ value: String) -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = value.data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                
                return 0
            }
        }
        
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension ASAuthorizationAppleIDCredential {
    var name: String? {
        guard let nameComponents = fullName else {
            return nil
        }
        var parts = [String]()
        
        if let givenName = nameComponents.givenName {
            parts.append(givenName)
        }
        
        if let familyName = nameComponents.familyName {
            parts.append(familyName)
        }
        
        guard !parts.isEmpty else {
            return nil
        }
        
        return parts.joined(separator: " ")
    }
}
