//
//  zzz.swift
//  Actito Go
//
//  Created by Helder Pinhal on 12/04/2022.
//

import Foundation
import ActitoKit
import OSLog

func extractCodeParameter(from url: URL) -> String? {
    guard url.scheme == "https" else {
        Logger.main.debug("Scheme mismatch.")
        return nil
    }
    
    guard url.host == "go-demo.ntc.re" || url.host == "go-demo-dev.ntc.re" else {
        Logger.main.debug("Host mismatch.")
        return nil
    }
    
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
          let queryItems = components.queryItems,
          let referrer = queryItems.first(where: { $0.name == "referrer" })?.value
    else {
        Logger.main.debug("Missing referrer parameter.")
        return nil
    }
    
    return referrer
}

func loadRemoteConfig() async {
    do {
        let assets = try await Actito.shared.assets().fetch(group: "config")
        
        if let config = assets.first, let storeEnabled = config.extra["storeEnabled"] as? Bool, storeEnabled {
            Preferences.standard.storeEnabled = true
            return
        }
    } catch {
        if case let ActitoNetworkError.validationError(response, _, _) = error, response.statusCode == 404 {
            // The config asset group is not available. The store can be enabled.
            Preferences.standard.storeEnabled = true
            return
        }
        
        Logger.main.error("Failed to fetch the remote config. \(error.localizedDescription)")
    }
    
    Preferences.standard.storeEnabled = false
}
