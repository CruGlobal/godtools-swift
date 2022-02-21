//
//  ToolPageCardViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageCardViewModelType: MobileContentViewModelType {
    
    var title: String? { get }
    var titleColor: UIColor { get }
    var titleFont: UIFont { get }
    var titleAlignment: NSTextAlignment { get }
    var hidesHeaderTrainingTip: Bool { get }
    var cardPositionLabel: String? { get }
    var cardPositionLabelTextColor: UIColor { get }
    var cardPositionLabelFont: UIFont { get }
    var hidesCardPositionLabel: Bool { get }
    var previousButtonTitle: String? { get }
    var previousButtonTitleColor: UIColor { get }
    var previousButtonTitleFont: UIFont { get }
    var hidesPreviousButton: Bool { get }
    var nextButtonTitle: String? { get }
    var nextButtonTitleColor: UIColor { get }
    var nextButtonTitleFont: UIFont { get }
    var hidesNextButton: Bool { get }
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute { get }
    var dismissListeners: [MultiplatformEventId] { get }
    var listeners: [MultiplatformEventId] { get }
    var isHiddenCard: Bool { get }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel?
    func cardDidAppear()
    func cardDidDisappear()
}
