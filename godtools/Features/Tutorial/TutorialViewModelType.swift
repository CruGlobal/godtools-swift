//
//  TutorialViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol TutorialViewModelType {
    
    var deviceLanguage: DeviceLanguageType { get }
    var tutorialItems: ObservableValue<[TutorialItem]> { get }
    var continueTitle: String { get }
    var startUsingGodToolsTitle: String { get }
    
    func closeTapped()
    func pageDidChange(page: Int)
    func pageDidAppear(page: Int)
    func continueTapped()
    func tutorialVideoPlayTapped()
}
