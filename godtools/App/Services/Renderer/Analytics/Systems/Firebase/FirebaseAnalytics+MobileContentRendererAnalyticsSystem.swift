//
//  FirebaseAnalytics+MobileContentRendererAnalyticsSystem.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

extension FirebaseAnalytics: MobileContentRendererAnalyticsSystem {
    
    func trackMobileContentAction(context: MobileContentRenderedPageContext, screenName: String, siteSection: String, action: String, data: [String: Any]?) {
        
        trackAction(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: "",
            contentLanguage: context.rendererLanguages.primaryLanguage.localeId,
            secondaryContentLanguage: context.rendererLanguages.parallelLanguage?.localeId,
            actionName: action,
            data: data
        )
    }
}
