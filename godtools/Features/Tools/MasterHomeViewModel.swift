//
//  MasterHomeViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class MasterHomeViewModel: MasterHomeViewModelType {
    
    private(set) weak var flowDelegate: FlowDelegate?
    
    let tutorialAvailability: TutorialAvailabilityType
    let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    let analytics: GodToolsAnaltyics
    
    required init(flowDelegate: FlowDelegate, tutorialAvailability: TutorialAvailabilityType, openTutorialCalloutCache: OpenTutorialCalloutCacheType, analytics: GodToolsAnaltyics) {
        
        self.flowDelegate = flowDelegate
        self.tutorialAvailability = tutorialAvailability
        self.openTutorialCalloutCache = openTutorialCalloutCache
        self.analytics = analytics
    }
    
    func menuTapped() {
        flowDelegate?.navigate(step: .menuTappedFromHome)
    }
    
    func languageTapped() {
        flowDelegate?.navigate(step: .languagesTappedFromHome)
    }
}
