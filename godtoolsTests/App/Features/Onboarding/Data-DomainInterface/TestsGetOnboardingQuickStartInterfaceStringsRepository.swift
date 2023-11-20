//
//  TestsGetOnboardingQuickStartInterfaceStringsRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 10/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

class TestsGetOnboardingQuickStartInterfaceStringsRepository: GetOnboardingQuickStartInterfaceStringsRepositoryInterface {
    
    init() {
        
    }
    
    func getStringsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<OnboardingQuickStartInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings: OnboardingQuickStartInterfaceStringsDomainModel
        
        if appLanguage == LanguageCodeDomainModel.english.value {
            
            interfaceStrings = getEnglishInterfaceStrings()
        }
        else if appLanguage == LanguageCodeDomainModel.spanish.rawValue {
            
            interfaceStrings = getSpanishInterfaceStrings()
        }
        else {
            
            interfaceStrings = getEnglishInterfaceStrings()
        }
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
    
    private func getEnglishInterfaceStrings() -> OnboardingQuickStartInterfaceStringsDomainModel {
        
        return OnboardingQuickStartInterfaceStringsDomainModel(
            title: "Quick Start Links",
            getStartedButtonTitle: "Get Started"
        )
    }
    
    private func getSpanishInterfaceStrings() -> OnboardingQuickStartInterfaceStringsDomainModel {
        
        return OnboardingQuickStartInterfaceStringsDomainModel(
            title: "Enlaces de inicio rápido",
            getStartedButtonTitle: "Empezar"
        )
    }
}
