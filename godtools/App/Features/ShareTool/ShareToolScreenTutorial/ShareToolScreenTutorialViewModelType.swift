//
//  ShareToolTutorialViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ShareToolScreenTutorialViewModelType {
        
    var customViewBuilder: CustomViewBuilderType { get }
    var tutorialItems: ObservableValue<[TutorialItem]> { get }
    var skipTitle: String { get }
    var continueTitle: String { get }
    var shareLinkTitle: String { get }
    
    func closeTapped()
    func shareLinkTapped()
}
