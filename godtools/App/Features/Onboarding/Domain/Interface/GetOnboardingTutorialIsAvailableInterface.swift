//
//  GetOnboardingTutorialIsAvailableInterface.swift
//  godtools
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetOnboardingTutorialIsAvailableInterface {
    
    func isAvailablePublisher() -> AnyPublisher<Bool, Never>
}
