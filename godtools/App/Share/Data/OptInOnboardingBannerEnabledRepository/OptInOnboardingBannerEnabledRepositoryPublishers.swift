//
//  OptInOnboardingBannerEnabledRepositoryPublishers.swift
//  godtools
//
//  Created by Levi Eggert on 7/8/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class OptInOnboardingBannerEnabledRepositoryPublishers {
    
    let enabled: CurrentValueSubject<Bool?, Never> = CurrentValueSubject(nil)
}
