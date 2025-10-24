//
//  Bundle+Version.swift
//  Actito Go
//
//  Created by Helder Pinhal on 31/08/2022.
//

import Foundation

internal extension Bundle {
    var applicationVersion: String {
        if let bundleShortVersion = self.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return bundleShortVersion
        } else if let bundleVersion = self.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            return bundleVersion
        }

        return ""
    }
}
