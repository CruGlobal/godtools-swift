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
    var hidesBackButton: ObservableValue<Bool> { get }
    var tutorialItems: ObservableValue<[TutorialItem]> { get }
    var continueButtonTitle: ObservableValue<String> { get }
    
    func closeTapped()
    func pageDidAppear(page: Int)
    func continueTapped()
    func tutorialVideoPlayTapped()
}
