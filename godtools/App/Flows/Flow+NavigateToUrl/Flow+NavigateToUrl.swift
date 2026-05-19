//
//  Flow+NavigateToUrl.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

extension Flow {
    
    func navigateToURL(url: URL, screenName: String, siteSection: String, siteSubSection: String, appLanguage: String?, contentLanguage: String?, contentLanguageSecondary: String?) {
        
        appDiContainer.core.domainLayer.getTrackExitLinkAnalyticsUseCase().trackExitLinkAnalytics(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            appLanguage: appLanguage,
            contentLanguage: contentLanguage,
            contentLanguageSecondary: contentLanguageSecondary,
            url: url
        )
            
        appDiContainer.getUrlOpener().open(url: url)
    }
}
