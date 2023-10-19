//
//  GetOnboardingQuickStartLinksRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetOnboardingQuickStartLinksRepositoryInterface {
    
    func getLinks(appLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<[OnboardingQuickStartLinkDomainModel], Never>
}
