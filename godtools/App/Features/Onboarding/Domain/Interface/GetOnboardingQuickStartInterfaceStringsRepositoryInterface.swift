//
//  GetOnboardingQuickStartInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetOnboardingQuickStartInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<OnboardingQuickStartInterfaceStringsDomainModel, Never>
}
