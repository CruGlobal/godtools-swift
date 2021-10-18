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
    var tutorialItems: ObservableValue<[TutorialItemType]> { get }
    var skipTitle: String { get }
    var continueTitle: String { get }
    var shareLinkTitle: String { get }
    
    func tutorialItemWillAppear(index: Int) -> TutorialCellViewModelType
    func closeTapped()
    func shareLinkTapped()
}
