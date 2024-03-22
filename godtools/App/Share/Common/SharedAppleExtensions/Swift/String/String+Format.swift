//
//  String+Format.swift
//  godtools
//
//  Created by Levi Eggert on 3/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

extension String {
    
    public static func localizedStringWithFormat(format: String, localeIdentifier: String, arguments: CVarArg...) -> String {
        
        return String(format: format, locale: Locale(identifier: localeIdentifier), arguments)
    }
}
