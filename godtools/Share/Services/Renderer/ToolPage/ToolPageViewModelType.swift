//
//  ToolPageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageViewModelType {
    
    var backgroundColor: UIColor { get }
    var backgroundImage: UIImage? { get }
    var contentStackViewModel: ToolPageContentStackViewModel? { get }
    var headerViewModel: ToolPageHeaderViewModel { get }
    var headerTrainingTipViewModel: TrainingTipViewModelType? { get }
    var heroViewModel: ToolPageContentStackViewModel? { get }
    var hidesCards: Bool { get }
    var cardsViewModels: [ToolPageCardViewModelType] { get }
    var currentCard: ObservableValue<AnimatableValue<Int?>> { get }
    var hiddenCard: ObservableValue<AnimatableValue<Int?>> { get }
    var callToActionViewModel: ToolPageCallToActionViewModel { get }
    var modal: ObservableValue<ToolPageModalViewModel?> { get }
    var hidesTrainingTip: Bool { get }
    
    func getCurrentPositions() -> ToolPageInitialPositions
    func callToActionNextButtonTapped()
    func hiddenCardWillAppear(cardPosition: Int) -> ToolPageCardViewModelType
}
