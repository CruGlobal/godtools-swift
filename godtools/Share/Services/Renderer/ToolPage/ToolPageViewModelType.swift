//
//  ToolPageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageViewModelTypeDelegate: class {
    
    func toolPagePresentedListener(viewModel: ToolPageViewModelType, page: Int)
    func toolPageTrainingTipTapped(trainingTipId: String, tipNode: TipNode)
    func toolPageCardChanged(cardPosition: Int?)
    func toolPageNextPageTapped()
    func toolPageError(error: ContentEventError)
}

protocol ToolPageViewModelType: NSObject {
    
    var backgroundColor: UIColor { get }
    var contentStackViewModel: ToolPageContentStackViewModel? { get }
    var headerViewModel: ToolPageHeaderViewModel { get }
    var headerTrainingTipViewModel: TrainingTipViewModelType? { get }
    var heroViewModel: ToolPageContentStackViewModel? { get }
    var hidesCards: Bool { get }
    var currentCard: ObservableValue<AnimatableValue<Int?>> { get }
    var callToActionViewModel: ToolPageCallToActionViewModel { get }
    var cardsViewModels: [ToolPageCardViewModelType] { get }
    var modal: ObservableValue<ToolPageModalViewModel?> { get }
    var hidesTrainingTip: Bool { get }
    var numberOfCards: Int { get }
    var numberOfVisibleCards: Int { get }
    var numberOfHiddenCards: Int { get }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel
    func getCurrentPositions() -> ToolPageInitialPositions
    func callToActionNextButtonTapped()
    func hiddenCardWillAppear(cardPosition: Int) -> ToolPageCardViewModelType?
    func setCard(cardPosition: Int?, animated: Bool)
}
