//
//  ToolPageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageViewModelTypeDelegate: class {
    
    func toolPagePresented(viewModel: ToolPageViewModelType, page: Int)
    func toolPageTrainingTipTapped(trainingTipId: String, tipNode: TipNode)
    func toolPageNextPageTapped()
    func toolPageError(error: ContentEventError)
}

protocol ToolPageViewModelType: NSObject {
    
    var backgroundColor: UIColor { get }
    var backgroundImage: UIImage? { get }
    var contentStackViewModel: ToolPageContentStackViewModel? { get }
    var headerViewModel: ToolPageHeaderViewModel { get }
    var headerTrainingTipViewModel: TrainingTipViewModelType? { get }
    var heroViewModel: ToolPageContentStackViewModel? { get }
    var hidesCards: Bool { get }
    var currentCardInVisibleCardStack: ObservableValue<AnimatableValue<Int?>> { get }
    var hiddenCardInHiddenCardStack: ObservableValue<AnimatableValue<Int?>> { get }
    var callToActionViewModel: ToolPageCallToActionViewModel { get }
    var modal: ObservableValue<ToolPageModalViewModel?> { get }
    var hidesTrainingTip: Bool { get }
    var numberOfVisibleCards: Int { get }
    
    func visibleCardsStackWillAppear() -> [ToolPageCardViewModelType]
    func getCurrentPositions() -> ToolPageInitialPositions
    func callToActionNextButtonTapped()
    func hiddenCardWillAppear(cardPosition: Int) -> ToolPageCardViewModelType?
    func setCardOrHiddenCard(cardPosition: Int?, animated: Bool)
}
