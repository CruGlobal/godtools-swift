//
//  OnboardingPathDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 8/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class OnboardingPathDeepLinkParser: DeepLinkUrlParserType {
    
    required init() {
        
    }
    
    func parse(url: URL, pathComponents: [String], queryParameters: [String : Any]) -> ParsedDeepLinkType? {
        
        guard pathComponents.first == "onboarding" else {
            return nil
        }
        
        let appLanguageCode: AppLanguageCodeDomainModel = (queryParameters["appLanguageCode"] as? String) ?? LanguageCodeDomainModel.english.value
        
        return .onboarding(appLanguageCode: appLanguageCode)
    }
}
