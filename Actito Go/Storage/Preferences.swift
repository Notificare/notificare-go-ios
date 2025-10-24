//
//  Preferences.swift
//  Actito Go
//
//  Created by Helder Pinhal on 15/03/2022.
//

import Combine
import Foundation
import OSLog

final class Preferences {
    static let standard = Preferences(userDefaults: .standard)
    
    fileprivate let userDefaults: UserDefaults
    
    /// Sends through the changed key path whenever a change occurs.
    var preferencesChangedSubject = PassthroughSubject<AnyKeyPath, Never>()
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    
    // MARK: Stored preferences
    
    @CodableUserDefault("app_configuration")
    var appConfiguration: AppConfiguration? = nil
    
    @UserDefault("intro_finished")
    var introFinished: Bool = false
    
    @UserDefault("store_enabled")
    var storeEnabled: Bool = false
    
    @CodableUserDefault("cart")
    var cart: [CartEntry] = []
    
    @UserDefault("membership_card_url")
    var membershipCardUrl: String? = nil
}

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    
    var wrappedValue: Value {
        get { fatalError("Wrapped value should not be used.") }
        set { fatalError("Wrapped value should not be used.") }
    }
    
    init(wrappedValue: Value, _ key: String) {
        self.defaultValue = wrappedValue
        self.key = key
    }
    
    public static subscript(
        _enclosingInstance instance: Preferences,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Preferences, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<Preferences, Self>
    ) -> Value {
        get {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key
            let defaultValue = instance[keyPath: storageKeyPath].defaultValue
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key
            container.set(newValue, forKey: key)
            instance.preferencesChangedSubject.send(wrappedKeyPath)
        }
    }
}

@propertyWrapper
struct CodableUserDefault<Value : Codable> {
    let key: String
    let defaultValue: Value
    
    var wrappedValue: Value {
        get { fatalError("Wrapped value should not be used.") }
        set { fatalError("Wrapped value should not be used.") }
    }
    
    init(wrappedValue: Value, _ key: String) {
        self.defaultValue = wrappedValue
        self.key = key
    }
    
    public static subscript(
        _enclosingInstance instance: Preferences,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Preferences, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<Preferences, Self>
    ) -> Value {
        get {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key
            let defaultValue = instance[keyPath: storageKeyPath].defaultValue
            
            do {
                if let encoded = container.data(forKey: key) {
                    let decoder = JSONDecoder()
                    return try decoder.decode(Value.self, from: encoded)
                }
             
                return defaultValue
            } catch {
                Logger.main.warning("Failed to decode value for '\(key)'.")
                return defaultValue
            }
        }
        set {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key
            
            do {
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(newValue)
                container.set(encoded, forKey: key)
                instance.preferencesChangedSubject.send(wrappedKeyPath)
            } catch {
                Logger.main.warning("Failed to encode value for '\(key)'.")
            }
        }
    }
}
