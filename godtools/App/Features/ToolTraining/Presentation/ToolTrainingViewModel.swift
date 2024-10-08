//
//  ToolTrainingViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser
import Combine
import LocalizationServices

class ToolTrainingViewModel: NSObject {
    
    private let pageRenderer: MobileContentPageRenderer
    private let renderedPageContext: MobileContentRenderedPageContext
    private let trainingTipId: String
    private let tipModel: Tip
    private let setCompletedTrainingTipUseCase: SetCompletedTrainingTipUseCase
    private let getTrainingTipCompletedUseCase: GetTrainingTipCompletedUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let localizationServices: LocalizationServices
    private let closeTappedClosure: (() -> Void)
    
    private var page: Int = 0
    private var cancellables = Set<AnyCancellable>()
        
    let progress: ObservableValue<AnimatableValue<CGFloat>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    let trainingTipBackgroundImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let trainingTipForegroundImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let title: ObservableValue<String> = ObservableValue(value: "")
    let continueButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    let numberOfTipPages: ObservableValue<Int> = ObservableValue(value: 0)
    
    init(pageRenderer: MobileContentPageRenderer, renderedPageContext: MobileContentRenderedPageContext, trainingTipId: String, tipModel: Tip, setCompletedTrainingTipUseCase: SetCompletedTrainingTipUseCase, getTrainingTipCompletedUseCase: GetTrainingTipCompletedUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, localizationServices: LocalizationServices, closeTappedClosure: @escaping (() -> Void)) {
        
        self.renderedPageContext = renderedPageContext
        self.pageRenderer = pageRenderer
        self.trainingTipId = trainingTipId
        self.tipModel = tipModel
        self.setCompletedTrainingTipUseCase = setCompletedTrainingTipUseCase
        self.getTrainingTipCompletedUseCase = getTrainingTipCompletedUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.localizationServices = localizationServices
        self.closeTappedClosure = closeTappedClosure
        
        super.init()
        
        let trainingTip = TrainingTipDomainModel(trainingTipId: trainingTipId, resourceId: resource.id, languageId: language.id)
        let trainingTipViewed = getTrainingTipCompletedUseCase.hasTrainingTipBeenCompleted(tip: trainingTip)
        
        reloadTitleAndTipIcon(
            tipModel: tipModel,
            trainingTipViewed: trainingTipViewed
        )
        
        numberOfTipPages.accept(value: tipModel.pages.count)
        setPage(page: 0, animated: false)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }

    private var resource: ResourceModel {
        return pageRenderer.resource
    }
    
    private var language: LanguageModel {
        return pageRenderer.language
    }
    
    private func getExitAnalyticsScreenName () -> String {
        return resource.abbreviation + "-tool-training"
    }
    
    private func getTipPageAnalyticsScreenName (tipPage: Int) -> String {
        return "\(resource.abbreviation)-tip-\(trainingTipId)-\(tipPage)"
    }
    
    private var analyticsSiteSection: String {
        return resource.abbreviation
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    private func setPage(page: Int, animated: Bool) {
        
        self.page = page
        
        let continueTitle: String
        if page < (numberOfTipPages.value - 1) {
            continueTitle = localizationServices.stringForLocaleElseEnglish(localeIdentifier: renderedPageContext.language.localeId, key: LocalizableStringKeys.cardNextButtonTitle.key)
        }
        else {
            continueTitle = localizationServices.stringForLocaleElseEnglish(localeIdentifier: renderedPageContext.language.localeId, key: LocalizableStringKeys.close.key)
        }
        continueButtonTitle.accept(value: continueTitle)

        if numberOfTipPages.value > 0 {
            let trainingProgress: CGFloat = CGFloat(page + 1) / CGFloat(numberOfTipPages.value)
            progress.accept(value: AnimatableValue(value: trainingProgress, animated: animated))
        }
    }
    
    private func reloadTitleAndTipIcon(tipModel: Tip, trainingTipViewed: Bool) {
        
        let tipBackgroundImageName: String = trainingTipViewed ? ImageCatalog.trainingTipRedSquareBg.name : ImageCatalog.trainingTipSquareBg.name
        let tipImageName: String
        let localizedTipTitle: String
        
        switch tipModel.type {
        
        case .ask:
            tipImageName = trainingTipViewed ? ImageCatalog.trainingTipAskFilledRed.name : ImageCatalog.trainingTipAsk.name
            localizedTipTitle = "training_tip_ask"
        
        case .consider:
            tipImageName = trainingTipViewed ? ImageCatalog.trainingTipConsiderFilledRed.name : ImageCatalog.trainingTipConsider.name
            localizedTipTitle = "training_tip_consider"
        
        case .prepare:
            tipImageName = trainingTipViewed ? ImageCatalog.trainingTipPrepareFilledRed.name : ImageCatalog.trainingTipPrepare.name
            localizedTipTitle = "training_tip_prepare"
        
        case .quote:
            tipImageName = trainingTipViewed ? ImageCatalog.trainingTipQuoteFilledRed.name : ImageCatalog.trainingTipQuote.name
            localizedTipTitle = "training_tip_quote"
        
        case .tip:
            tipImageName = trainingTipViewed ? ImageCatalog.trainingTipTipFilledRed.name : ImageCatalog.trainingTipTip.name
            localizedTipTitle = "training_tip_tip"
        
        default:
            tipImageName = ""
            localizedTipTitle = ""
        }
        
        let tipTitle: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: renderedPageContext.language.localeId, key: localizedTipTitle)
        
        trainingTipBackgroundImage.accept(value: UIImage(named: tipBackgroundImageName))
        trainingTipForegroundImage.accept(value: UIImage(named: tipImageName))
        title.accept(value: tipTitle)
    }
}

// MARK: - Inputs

extension ToolTrainingViewModel {
    
    func viewLoaded() {
        
        let trainingTipCompleted = TrainingTipDomainModel(trainingTipId: trainingTipId, resourceId: resource.id, languageId: language.id)
        
        setCompletedTrainingTipUseCase.setTrainingTipAsCompleted(tip: trainingTipCompleted)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    func overlayTapped() {
        closeTappedClosure()
    }
    
    func closeTapped() {
        closeTappedClosure()
    }
    
    func continueTapped() {
        
        let nextPage: Int = page + 1
        let reachedEnd: Bool = nextPage >= numberOfTipPages.value
        
        if reachedEnd {
            closeTappedClosure()
        }
    }
    
    func buttonWithUrlTapped(url: URL) {
        
        renderedPageContext.navigation.buttonWithUrlTapped(
            url: url,
            analyticsScreenName: getExitAnalyticsScreenName(),
            analyticsSiteSection: analyticsSiteSection,
            analyticsSiteSubSection: analyticsSiteSubSection,
            languages: renderedPageContext.rendererLanguages
        )
    }
    
    func tipPageWillAppear(page: Int, window: UIViewController, safeArea: UIEdgeInsets) -> MobileContentView? {
              
        guard page >= 0 && page < tipModel.pages.count else {
            return nil
        }
        
        return pageRenderer.viewRenderer.recurseAndRender(
            renderableModel: tipModel.pages[page],
            renderableModelParent: nil,
            renderedPageContext: renderedPageContext
        )
    }
    
    func tipPageDidChange(page: Int) {
        setPage(page: page, animated: true)
    }
    
    func tipPageDidAppear(page: Int) {
       
        setPage(page: page, animated: true)
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: getTipPageAnalyticsScreenName(tipPage: page),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
}
