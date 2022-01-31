//
//  SetupParallelLanguageAvailabilityType.swift
//  godtools
//
//  Created by Robert Eldredge on 1/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol SetupParallelLanguageAvailabilityType {
    
    var setupParallelLanguageIsAvailable: Bool { get }
    
    func markSetupParallelLanguageViewed()
}
