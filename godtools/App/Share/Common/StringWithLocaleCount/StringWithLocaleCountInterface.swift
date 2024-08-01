//
//  StringWithLocaleCountInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

protocol StringWithLocaleCountInterface {
 
    func getString(format: String, locale: Locale, count: Int) -> String
}
