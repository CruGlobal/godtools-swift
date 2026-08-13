//
//  MobileContentRendererAnalyticsSystem.swift
//  godtools
//
//  Created by Levi Eggert on 11/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol MobileContentRendererAnalyticsSystem: Actor {
    
    func trackMobileContentAction(
        screenName: String,
        siteSection: String,
        appLanguage: AppLanguageDomainModel,
        contentLanguage: BCP47LanguageIdentifier,
        secondaryContentLanguage: BCP47LanguageIdentifier?,
        action: String,
        data: [String: Any]?
    ) async throws
}
