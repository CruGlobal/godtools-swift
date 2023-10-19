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
    
    func getStringsPublisher(appLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<OnboardingQuickStartInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings: OnboardingQuickStartInterfaceStringsDomainModel
        
        if appLanguageCode == LanguageCodeDomainModel.english.value {
            
            interfaceStrings = getEnglishInterfaceStrings()
        }
        else if appLanguageCode == LanguageCodeDomainModel.spanish.rawValue {
            
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
