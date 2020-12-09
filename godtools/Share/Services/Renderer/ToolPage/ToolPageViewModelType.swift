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
    func toolPageTrainingTipTapped(viewModel: ToolPageViewModelType, page: Int, trainingTipId: String, tipNode: TipNode)
    func toolPageCardChanged(viewModel: ToolPageViewModelType, page: Int, cardPosition: Int?)
    func toolPageNextPageTapped(viewModel: ToolPageViewModelType, page: Int)
    func toolPageError(viewModel: ToolPageViewModelType, page: Int, error: ContentEventError)
}

protocol ToolPageViewModelType: NSObject {
    
    var backgroundColor: UIColor { get }
    var contentStackViewModel: ToolPageContentStackContainerViewModel? { get }
    var headerViewModel: ToolPageHeaderViewModel { get }
    var headerTrainingTipViewModel: TrainingTipViewModelType? { get }
    var heroViewModel: ToolPageHeroViewModel? { get }
    var hidesCards: Bool { get }
    var currentCard: ObservableValue<AnimatableValue<Int?>> { get }
    var callToActionViewModel: ToolPageCallToActionViewModel { get }
    var cardsViewModels: [ToolPageCardViewModelType] { get }
    var modal: ObservableValue<ToolPageModalViewModel?> { get }
    var hidesHeaderTrainingTip: ObservableValue<Bool> { get }
    var numberOfCards: Int { get }
    var numberOfVisibleCards: Int { get }
    var numberOfHiddenCards: Int { get }
    var hidesCardJump: ObservableValue<Bool> { get }
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute { get }
    var bottomViewColor: UIColor { get }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel
    func getCurrentPositions() -> ToolPageInitialPositions
    func callToActionNextButtonTapped()
    func hiddenCardWillAppear(cardPosition: Int) -> ToolPageCardViewModelType?
    func setCard(cardPosition: Int?, animated: Bool)
    func pageDidAppear()
    func pageDidDisappear()
    func cardBounceAnimationFinished()
}
