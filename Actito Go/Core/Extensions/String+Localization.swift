//
//  String+Localization.swift
//  Actito Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import Foundation

extension String {    
    init(localized: String, comment: String = "", _ arguments: CVarArg...) {
        let localizedString = NSLocalizedString(localized, comment: comment)
        self = String(format: localizedString, arguments: arguments)
    }
}
