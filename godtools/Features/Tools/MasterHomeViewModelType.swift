//
//  MasterHomeViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol MasterHomeViewModelType {
    
    var flowDelegate: FlowDelegate? { get }
    var tutorialAvailability: TutorialAvailabilityType { get }
    var openTutorialCalloutCache: OpenTutorialCalloutCacheType { get }
    var analytics: AnalyticsContainer { get }
    
    func menuTapped()
    func languageTapped()
}
