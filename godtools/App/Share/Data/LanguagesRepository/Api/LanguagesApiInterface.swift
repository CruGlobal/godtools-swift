//
//  LanguagesApiInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol LanguagesApiInterface {
    
    func getLanguage(requestPriority: RequestPriority, languageId: String) async throws -> LanguageCodable?
    func getLanguages(requestPriority: RequestPriority) async throws -> [LanguageCodable]
}
