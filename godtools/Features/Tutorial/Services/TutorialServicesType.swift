//
//  TutorialServicesType.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol TutorialServicesType {
    
    var tutorialIsAvailable: Bool { get }
    var openTutorialCalloutIsAvailable: Bool { get }
    var openTutorialCalloutDisabledSignal: Signal { get }
    
    func enableOpenTutorialCallout()
    func disableOpenTutorialCallout()
}
