//
//  StoreOnboardingTutorialViewedRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol StoreOnboardingTutorialViewedRepositoryInterface {
    
    func storeViewedPublisher() -> AnyPublisher<Void, Never>
}
