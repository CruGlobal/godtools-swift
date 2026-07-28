//
//  AppLanguagesApiInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol AppLanguagesApiInterface: Sendable {
    
    func getAppLanguages() async throws -> [AppLanguageCodable]
}
