//
//  ToolPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageViewModel: ToolPageViewModelType {
    
    private let pageNode: PageNode
    private let pageModel: MobileContentRendererPageModel
    private let toolPageColors: ToolPageColors
    
    required init(pageNode: PageNode, pageModel: MobileContentRendererPageModel, toolPageColors: ToolPageColors) {
        
        self.pageNode = pageNode
        self.pageModel = pageModel
        self.toolPageColors = toolPageColors
    }
    
    var backgroundColor: UIColor {
        return toolPageColors.backgroundColor
    }
    
    var bottomViewColor: UIColor {
        
        let manifestAttributes: MobileContentXmlManifestAttributes = pageModel.manifest.attributes
        let color: UIColor = manifestAttributes.getNavBarColor()?.color ?? manifestAttributes.getPrimaryColor().color
        
        return color.withAlphaComponent(0.1)
    }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel? {
                    
        let manifestAttributes: MobileContentXmlManifestAttributes = pageModel.manifest.attributes
        
        let backgroundImageNode: BackgroundImageNodeType?
        
        if pageNode.backgroundImageExists {
            backgroundImageNode = pageNode
        }
        else if manifestAttributes.backgroundImageExists {
            backgroundImageNode = manifestAttributes
        }
        else {
            backgroundImageNode = nil
        }
        
        if let backgroundImageNode = backgroundImageNode {
            return MobileContentBackgroundImageViewModel(
                backgroundImageNode: backgroundImageNode,
                manifestResourcesCache: pageModel.resourcesCache,
                languageDirection: pageModel.language.languageDirection
            )
        }
        
        return nil
    }
}

/*
class ToolPageViewModel: NSObject, ToolPageViewModelType {
        
    private let pageNode: PageNode
    private let diContainer: ToolPageDiContainer
    private let toolPageColors: ToolPageColors
    private let page: Int
    private let initialPositions: ToolPageInitialPositions?
    private let isLastPage: Bool

    private var allCardsViewModels: [ToolPageCardViewModelType] = Array()
    private var visibleCardsViewModels: [ToolPageCardViewModelType] = Array()
    private var hiddenCardsViewModels: [ToolPageCardViewModel] = Array()
    
    private(set) var modalViewModels: [ToolPageModalViewModel] = Array()
    
    private weak var delegate: ToolPageViewModelTypeDelegate?
    
    let contentStackViewModel: ToolPageContentStackContainerViewModel?
    let headerTrainingTipViewModel: TrainingTipViewModelType?
    let hidesCards: Bool
    let currentCard: ObservableValue<AnimatableValue<Int?>> = ObservableValue(value: AnimatableValue(value: nil, animated: false))
    let modal: ObservableValue<ToolPageModalViewModel?> = ObservableValue(value: nil)
    let hidesHeaderTrainingTip: ObservableValue<Bool> = ObservableValue(value: true)
    
    required init(pageNode: PageNode, diContainer: ToolPageDiContainer, page: Int, initialPositions: ToolPageInitialPositions?) {
                
        let isLastPage: Bool = page >= diContainer.manifest.pages.count - 1
        
        self.pageNode = pageNode
        self.diContainer = diContainer
        self.toolPageColors = ToolPageColors(pageNode: pageNode, manifest: diContainer.manifest)
        self.page = page
        self.initialPositions = initialPositions
        self.isLastPage = isLastPage
        
        // content stack
        let firstNodeIsContentParagraph: Bool = pageNode.children.first is ContentParagraphNode
        
        if firstNodeIsContentParagraph {
            
            contentStackViewModel = ToolPageContentStackContainerViewModel(
                node: pageNode,
                diContainer: diContainer,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: nil,
                defaultTextNodeTextAlignment: nil,
                defaultButtonBorderColor: nil
            )
        }
        else {
            contentStackViewModel = nil
        }
        
        // headerTrainingTipViewModel
        if let trainingTipId = pageNode.headerNode?.trainingTip, !trainingTipId.isEmpty {
            
            headerTrainingTipViewModel = TrainingTipViewModel(
                trainingTipId: trainingTipId,
                resource: diContainer.resource,
                language: diContainer.language,
                manifest: diContainer.manifest,
                translationsFileCache: diContainer.translationsFileCache,
                mobileContentNodeParser: diContainer.mobileContentNodeParser,
                mobileContentEvents: diContainer.mobileContentEvents,
                viewType: .upArrow,
                viewedTrainingTips: diContainer.viewedTrainingTips
            )
        }
        else {
            headerTrainingTipViewModel = nil
        }
                
        // cards
        hidesCards = pageNode.cardsNode?.cards.isEmpty ?? true
        
        super.init()
        
        let cardNodes: [CardNode] = pageNode.cardsNode?.cards ?? []
        
        var visibleCards: [CardNode] = Array()
        var hiddenCards: [CardNode] = Array()
        
        for cardNode in cardNodes {
            
            if cardNode.hidden != "true" {
                visibleCards.append(cardNode)
            }
            else {
                hiddenCards.append(cardNode)
            }
        }
                
        for visibleCardIndex in 0 ..< visibleCards.count {
            
            let visibleCardNode: CardNode = visibleCards[visibleCardIndex]
            
            let cardViewModel = ToolPageCardViewModel(
                delegate: self,
                cardNode: visibleCardNode,
                diContainer: diContainer,
                cardPosition: allCardsViewModels.count,
                visibleCardPosition: visibleCardIndex,
                hiddenCardPosition: nil,
                numberOfCards: visibleCards.count,
                toolPageColors: toolPageColors,
                isLastPage: isLastPage
            )
            
            visibleCardsViewModels.append(cardViewModel)
            allCardsViewModels.append(cardViewModel)
        }
        
        for hiddenCardIndex in 0 ..< hiddenCards.count {
            
            let hiddenCardNode: CardNode = hiddenCards[hiddenCardIndex]
            
            let cardViewModel = ToolPageCardViewModel(
                delegate: self,
                cardNode: hiddenCardNode,
                diContainer: diContainer,
                cardPosition: allCardsViewModels.count,
                visibleCardPosition: nil,
                hiddenCardPosition: hiddenCardIndex,
                numberOfCards: hiddenCards.count,
                toolPageColors: toolPageColors,
                isLastPage: isLastPage
            )
            
            hiddenCardsViewModels.append(cardViewModel)
            allCardsViewModels.append(cardViewModel)
        }
        
        // modals
        let modalNodes: [ModalNode] = pageNode.modalsNode?.modals ?? []
        
        for modalNode in modalNodes {
            
            let modalViewModel = ToolPageModalViewModel(
                delegate: self,
                modalNode: modalNode,
                diContainer: diContainer,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: toolPageColors.primaryTextColor
            )
            
            modalViewModels.append(modalViewModel)
        }
        
        // initialPositions
        if let initialPositions = self.initialPositions {
            if let cardPosition = initialPositions.card, allCardsViewModels.count > 0 {
                setCard(cardPosition: cardPosition, animated: false)
            }
        }
        
        reloadTrainingTipsEnabled(trainingTipsEnabled: diContainer.trainingTipsEnabled)
        
        setupBinding()
        
        hidesCardJump.accept(value: diContainer.cardJumpService.didShowCardJump)
    }
    
    private func setupBinding() {
        
    }
    
    private func reloadTrainingTipsEnabled(trainingTipsEnabled: Bool) {
                
        hidesHeaderTrainingTip.accept(value: getHidesHeaderTrainingTip(trainingTipsEnabled: trainingTipsEnabled))
    }
    
    private func getHidesHeaderTrainingTip(trainingTipsEnabled: Bool) -> Bool {
        guard trainingTipsEnabled else {
            return true
        }
        guard let pageHeaderTrainingTip = pageNode.headerNode?.trainingTip else {
            return true
        }
        guard !pageHeaderTrainingTip.isEmpty else {
            return true
        }
        return false
    }
    
    var backgroundColor: UIColor {
        return toolPageColors.backgroundColor
    }
    
    var numberOfCards: Int {
        return allCardsViewModels.count
    }
    
    var numberOfVisibleCards: Int {
        return visibleCardsViewModels.count
    }
    
    var numberOfHiddenCards: Int {
        return hiddenCardsViewModels.count
    }
    
    var cardsViewModels: [ToolPageCardViewModelType] {
        return allCardsViewModels
    }s
    
    func getCurrentPositions() -> ToolPageInitialPositions {
        
        return ToolPageInitialPositions(page: page, card: currentCard.value.value)
    }
    
    func callToActionNextButtonTapped() {
        delegate?.toolPageNextPageTapped(viewModel: self, page: page)
    }
    
    func hiddenCardWillAppear(cardPosition: Int) -> ToolPageCardViewModelType? {
        if cardPosition >= 0 && cardPosition < hiddenCardsViewModels.count {
            return hiddenCardsViewModels[cardPosition]
        }
        return nil
    }
    
    func setCard(cardPosition: Int?, animated: Bool) {
        
        if let currentCardPosition = currentCard.value.value, currentCardPosition != cardPosition {
            if currentCardPosition >= 0 && currentCardPosition < allCardsViewModels.count {
                allCardsViewModels[currentCardPosition].cardWillDisappear()
            }
        }
        
        if let newCardPosition = cardPosition, newCardPosition != currentCard.value.value {
            if newCardPosition >= 0 && newCardPosition < allCardsViewModels.count {
                allCardsViewModels[newCardPosition].cardWillAppear()
            }
        }
        
        if let cardPosition = cardPosition, cardPosition >= 0 && cardPosition < allCardsViewModels.count {
            currentCard.accept(value: AnimatableValue(value: cardPosition, animated: animated))
        }
        else {
            currentCard.accept(value: AnimatableValue(value: nil, animated: animated))
        }
        
        delegate?.toolPageCardChanged(viewModel: self, page: page, cardPosition: cardPosition)
        
        if let cardPosition = cardPosition {
            trackCardAnalytics(cardPosition: cardPosition)
        }
    }
    
    private func trackCardAnalytics(cardPosition: Int) {
        
        let pageAnalyticsScreenName: String = diContainer.resource.abbreviation + "-" + String(page)
        let screenName: String = pageAnalyticsScreenName + ToolPageCardAnalyticsScreenName(cardPosition: cardPosition).screenName
        diContainer.analytics.pageViewedAnalytics.trackPageView(screenName: screenName, siteSection: "", siteSubSection: "")
    }
}

// MARK: - ToolPageModalViewModelDelegate

extension ToolPageViewModel: ToolPageModalViewModelDelegate {
    
    func presentModal(modalViewModel: ToolPageModalViewModel) {
        modal.accept(value: modalViewModel)
    }
    
    func dismissModal(modalViewModel: ToolPageModalViewModel) {
        modal.accept(value: nil)
    }
}
*/
