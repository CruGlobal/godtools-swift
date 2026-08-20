//
//  DeviceSystemLanguageInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

protocol DeviceSystemLanguageInterface: Sendable {
    
    func getLocale() -> Locale
}
