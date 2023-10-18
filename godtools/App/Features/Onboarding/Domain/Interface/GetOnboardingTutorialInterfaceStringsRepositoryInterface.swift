//
//  GetOnboardingTutorialInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetOnboardingTutorialInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(appLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<OnboardingTutorialInterfaceStringsDomainModel, Never>
}
