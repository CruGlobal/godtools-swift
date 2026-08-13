//
//  Flow+NavigateToUrl.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

extension GTFlow {
    
    func navigateToURL(linkTapped: URLLinkTappedParams, appLanguage: String?) {
        
        let trackExitLinkAnalytics = appDiContainer.core.domainLayer.getTrackExitLinkAnalyticsUseCase()
        
        Task {
            
            await trackExitLinkAnalytics.execute(
                properties: AnalyticsProperties(
                    screenName: linkTapped.screenName,
                    siteSection: linkTapped.siteSection,
                    siteSubSection: linkTapped.siteSubSection,
                    appLanguage: appLanguage,
                    contentLanguage: linkTapped.contentLanguage,
                    secondaryContentLanguage: linkTapped.contentLanguageSecondary
                ),
                url: linkTapped.url
            )
        }
            
        appDiContainer.getUrlOpener().open(url: linkTapped.url)
    }
}
