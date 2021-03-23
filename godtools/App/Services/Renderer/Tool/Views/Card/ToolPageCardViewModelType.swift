//
//  ToolPageCardViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageCardViewModelTypeDelegate: class {
    
    func headerTappedFromCard(cardViewModel: ToolPageCardViewModelType, cardPosition: Int)
    func previousTappedFromCard(cardViewModel: ToolPageCardViewModelType, cardPosition: Int)
    func nextTappedFromCard(cardViewModel: ToolPageCardViewModelType, cardPosition: Int)
    func cardSwipedUpFromCard(cardViewModel: ToolPageCardViewModelType, cardPosition: Int)
    func cardSwipedDownFromCard(cardViewModel: ToolPageCardViewModelType, cardPosition: Int)
    func presentCardListener(cardViewModel: ToolPageCardViewModelType, cardPosition: Int)
    func dismissCardListener(cardViewModel: ToolPageCardViewModelType, cardPosition: Int)
}

protocol ToolPageCardViewModelType: NSObject {
    
    var title: String? { get }
    var titleColor: UIColor { get }
    var titleFont: UIFont { get }
    var titleAlignment: NSTextAlignment { get }
    var hidesHeaderTrainingTip: ObservableValue<Bool> { get }
    var isHiddenCard: Bool { get }
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
    
    func setDelegate(delegate: ToolPageCardViewModelTypeDelegate)
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel
    func cardWillAppear()
    func cardWillDisappear()
}
