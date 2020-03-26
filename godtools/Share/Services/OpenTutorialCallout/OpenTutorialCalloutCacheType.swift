//
//  OpenTutorialCalloutCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol OpenTutorialCalloutCacheType {
    
    var openTutorialCalloutEnabled: Bool { get }
    var openTutorialCalloutDisabled: Bool { get }
    var openTutorialCalloutDisabledSignal: Signal { get }
    
    func enableOpenTutorialCallout()
    func disableOpenTutorialCallout()
}
