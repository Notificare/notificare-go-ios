//
//  AppConfiguration.swift
//  Actito Go
//
//  Created by Helder Pinhal on 25/03/2022.
//

import Foundation

struct AppConfiguration: Codable {
    let applicationKey: String
    let applicationSecret: String
    let loyaltyProgramId: String?
}
