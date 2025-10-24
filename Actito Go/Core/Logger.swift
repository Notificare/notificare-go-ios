//
//  Logger.swift
//  Actito Go
//
//  Created by Helder Pinhal on 21/06/2022.
//

import Foundation
import OSLog

extension Logger {
    static let main: Logger = Logger.init(subsystem: "re.notifica.go", category: "Actito Go")
}
