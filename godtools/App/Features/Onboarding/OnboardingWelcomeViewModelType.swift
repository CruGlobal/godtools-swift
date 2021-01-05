//
//  OnboardingWelcomeViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol OnboardingWelcomeViewModelType {
    
    var logo: ObservableValue<UIImage?> { get }
    var title: ObservableValue<String> { get }
    var beginTitle: ObservableValue<String> { get }
    
    func pageViewed()
    func changeTitleToTagline()
    func beginTapped()
}
