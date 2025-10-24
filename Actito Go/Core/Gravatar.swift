//
//  Gravatar.swift
//  Actito Go
//
//  Created by Helder Pinhal on 06/06/2022.
//

import Foundation

internal func getGravatarUrl(email: String) -> URL {
    let hash = sha256(email.lowercased())
    return URL(string: "https://gravatar.com/avatar/\(hash)?s=400&d=retro")!
}
