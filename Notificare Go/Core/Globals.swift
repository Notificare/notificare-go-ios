//
//  zzz.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 12/04/2022.
//

import Foundation
import NotificareKit

func extractCodeParameter(from url: URL) -> String? {
    guard url.scheme == "https" else {
        print("Scheme mismatch.")
        return nil
    }
    
    guard url.host == "go-demo.ntc.re" || url.host == "go-demo-dev.ntc.re" else {
        print("Host mismatch.")
        return nil
    }
    
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
          let queryItems = components.queryItems,
          let referrer = queryItems.first(where: { $0.name == "referrer" })?.value
    else {
        print("Missing referrer parameter.")
        return nil
    }
    
    return referrer
}

func loadRemoteConfig() async {
    do {
        let assets = try await Notificare.shared.assets().fetch(group: "config")
        
        if let config = assets.first, let storeEnabled = config.extra["storeEnabled"] as? Bool, storeEnabled {
            Preferences.standard.storeEnabled = true
            return
        }
    } catch {
        if case let NotificareNetworkError.validationError(response, _, _) = error, response.statusCode == 404 {
            // The config asset group is not available. The store can be enabled.
            Preferences.standard.storeEnabled = true
            return
        }
        
        print("Failed to fetch the remote config. \(error)")
    }
    
    Preferences.standard.storeEnabled = false
}
