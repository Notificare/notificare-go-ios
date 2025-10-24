//
//  UserInfo.swift
//  Actito Go
//
//  Created by Helder Pinhal on 06/06/2022.
//

import Foundation
import FirebaseAuth

struct UserInfo {
    let id: String
    let name: String?
    let pictureUrl: URL?
}

extension UserInfo {
    init(user: FirebaseAuth.User) {
        self.id = user.uid
        self.name = user.displayName
        
        if let email = user.email {
            self.pictureUrl = getGravatarUrl(email: email)
        } else {
            self.pictureUrl = nil
        }
    }
}
