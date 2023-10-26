//
//  TestsGetOnboardingQuickStartLinksRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 10/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

class TestsGetOnboardingQuickStartLinksRepository: GetOnboardingQuickStartLinksRepositoryInterface {
    
    func getLinks(appLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<[OnboardingQuickStartLinkDomainModel], Never> {
        
        let links: [OnboardingQuickStartLinkDomainModel]
        
        if appLanguageCode == LanguageCodeDomainModel.english.value {
            
            links = getEnglishLinks()
        }
        else if appLanguageCode == LanguageCodeDomainModel.spanish.rawValue {
            
            links = getSpanishLinks()
        }
        else {
            
            links = getEnglishLinks()
        }
        
        return Just(links)
            .eraseToAnyPublisher()
    }
    
    private func getEnglishLinks() -> [OnboardingQuickStartLinkDomainModel] {
        
        return [
            OnboardingQuickStartLinkDomainModel(
                title: "English Title",
                actionTitle: "",
                analyticsEventActionName: "",
                linkType: .chooseOneOfOurTools
            )
        ]
    }
    
    private func getSpanishLinks() -> [OnboardingQuickStartLinkDomainModel] {
        
        return [
            OnboardingQuickStartLinkDomainModel(
                title: "Título en inglés",
                actionTitle: "",
                analyticsEventActionName: "",
                linkType: .chooseOneOfOurTools
            )
        ]
    }
}
