//
//  GetOnboardingQuickStartSupportedLanguagesRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetOnboardingQuickStartSupportedLanguagesRepositoryInterface {
    
    func getLanguagesPublisher() -> AnyPublisher<[LanguageCodeDomainModel], Never>
}
