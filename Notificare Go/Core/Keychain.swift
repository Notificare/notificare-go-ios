//
//  Keychain.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 10/03/2022.
//

import Foundation

class Keychain {
    static let standard = Keychain(service: Bundle.main.bundleIdentifier!)
    
    let service: String
    
    var user: CurrentUser? {
        get {
            do {
                return try fetch(account: "user_identifier")
            } catch {
                //
                return nil
            }
        }
        set {
            do {
                if let value = newValue {
                    try store(value, account: "user_identifier")
                } else {
                    try remove(account: "user_identifier")
                }
            } catch {
                //
            }
        }
    }
    
    init(service: String) {
        self.service = service
    }
    
    private func fetch(account: String, accessGroup: String? = nil) throws -> String {
        let data: Data = try fetch(account: account, accessGroup: accessGroup)
        
        guard let decoded = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedPasswordData
        }
        
        return decoded
    }
    
    private func fetch<T: Decodable>(account: String, accessGroup: String? = nil) throws -> T {
        let data: Data = try fetch(account: account, accessGroup: accessGroup)
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    private func fetch(account: String, accessGroup: String? = nil) throws -> Data {
        var query = query(account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError }
        
        // Parse the password string from the query result.
        guard let existingItem = queryResult as? [String: AnyObject],
              let data = existingItem[kSecValueData as String] as? Data
        else {
            throw KeychainError.unexpectedPasswordData
        }
        
        return data
    }
    
    
    private func store(_ value: String, account: String, accessGroup: String? = nil) throws {
        guard let encoded = value.data(using: .utf8) else { return }
        
        try store(encoded, account: account, accessGroup: accessGroup)
    }
    
    private func store<T : Encodable>(_ value: T, account: String, accessGroup: String? = nil) throws {
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(value)
        
        try store(encoded, account: account, accessGroup: accessGroup)
    }
    
    private func store(_ value: Data, account: String, accessGroup: String? = nil) throws {
        do {
            // Check for an existing item in the keychain.
            let _ : Data = try fetch(account: account, accessGroup: accessGroup)
            
            // Update the existing item with the new password.
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = value as AnyObject?
            
            let query = query(account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError }
        } catch KeychainError.noPassword {
            /*
             No password was found in the keychain. Create a dictionary to save
             as a new keychain item.
             */
            var newItem = query(account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = value as AnyObject?
            
            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError }
        }
    }
    
    private func remove(account: String, accessGroup: String? = nil) throws {
        // Delete the existing item from the keychain.
        let query = query(account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError }
    }
    
    private func query(account: String, accessGroup: String? = nil) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        query[kSecAttrAccount as String] = account as AnyObject?
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unexpectedItemData
    case unhandledError
}
