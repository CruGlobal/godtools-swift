//
//  OnboardingQuickStartViewModelType.swift
//  godtools
//
//  Created by Robert Eldredge on 11/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol OnboardingQuickStartViewModelType {
    
    var title: String { get }
    var skipButtonTitle: String { get }
    var endTutorialButtonTitle: String { get }
    var quickStartItemCount: Int { get }
    
    func quickStartCellWillAppear(index: Int) -> OnboardingQuickStartItem
    func quickStartCellLinkButtonTapped(flowStep: FlowStep)
    func skipButtonTapped()
    func endTutorialButtonTapped()
}
