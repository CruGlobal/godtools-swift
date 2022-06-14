//
//  ToolTrainingViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ToolTrainingViewModel: NSObject, ToolTrainingViewModelType {
    
    private let pageRenderer: MobileContentPageRenderer
    private let renderedPageContext: MobileContentRenderedPageContext
    private let trainingTipId: String
    private let tipModel: Tip
    private let analytics: AnalyticsContainer
    private let localizationServices: LocalizationServices
    private let viewedTrainingTips: ViewedTrainingTipsService
    private let closeTappedClosure: (() -> Void)
    
    private var page: Int = 0
        
    let progress: ObservableValue<AnimatableValue<CGFloat>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    let trainingTipBackgroundImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let trainingTipForegroundImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let title: ObservableValue<String> = ObservableValue(value: "")
    let continueButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    let numberOfTipPages: ObservableValue<Int> = ObservableValue(value: 0)
    
    required init(pageRenderer: MobileContentPageRenderer, renderedPageContext: MobileContentRenderedPageContext, trainingTipId: String, tipModel: Tip, analytics: AnalyticsContainer, localizationServices: LocalizationServices, viewedTrainingTips: ViewedTrainingTipsService, closeTappedClosure: @escaping (() -> Void)) {
        
        self.renderedPageContext = renderedPageContext
        self.pageRenderer = pageRenderer
        self.trainingTipId = trainingTipId
        self.tipModel = tipModel
        self.analytics = analytics
        self.localizationServices = localizationServices
        self.viewedTrainingTips = viewedTrainingTips
        self.closeTappedClosure = closeTappedClosure
        
        super.init()
        
        reloadTitleAndTipIcon(
            tipModel: tipModel,
            trainingTipViewed: viewedTrainingTips.containsViewedTrainingTip(viewedTrainingTip: ViewedTrainingTip(trainingTipId: trainingTipId, resourceId: resource.id, languageId: language.id))
        )
        
        numberOfTipPages.accept(value: tipModel.pages.count)
        setPage(page: 0, animated: false)
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
            continueTitle = localizationServices.stringForMainBundle(key: "card_status2")
        }
        else {
            continueTitle = localizationServices.stringForMainBundle(key: "close")
        }
        continueButtonTitle.accept(value: continueTitle)

        if numberOfTipPages.value > 0 {
            let trainingProgress: CGFloat = CGFloat(page + 1) / CGFloat(numberOfTipPages.value)
            progress.accept(value: AnimatableValue(value: trainingProgress, animated: animated))
        }
    }
    
    private func reloadTitleAndTipIcon(tipModel: Tip, trainingTipViewed: Bool) {
        
        let tipBackgroundImageName: String = trainingTipViewed ? "training_tip_red_square_bg" : "training_tip_square_bg"
        let tipImageName: String
        let localizedTipTitle: String
        
        switch tipModel.type {
        case .ask:
            tipImageName = trainingTipViewed ? "training_tip_ask_filled_red" : "training_tip_ask"
            localizedTipTitle = "training_tip_ask"
        case .consider:
            tipImageName = trainingTipViewed ? "training_tip_consider_filled_red" : "training_tip_consider"
            localizedTipTitle = "training_tip_consider"
        case .prepare:
            tipImageName = trainingTipViewed ? "training_tip_prepare_filled_red" : "training_tip_prepare"
            localizedTipTitle = "training_tip_prepare"
        case .quote:
            tipImageName = trainingTipViewed ? "training_tip_quote_filled_red" : "training_tip_quote"
            localizedTipTitle = "training_tip_quote"
        case .tip:
            tipImageName = trainingTipViewed ? "training_tip_tip_filled_red" : "training_tip_tip"
            localizedTipTitle = "training_tip_tip"
        default:
            tipImageName = ""
            localizedTipTitle = ""
        }
        
        let tipTitle: String = localizationServices.stringForMainBundle(key: localizedTipTitle)
        
        trainingTipBackgroundImage.accept(value: UIImage(named: tipBackgroundImageName))
        trainingTipForegroundImage.accept(value: UIImage(named: tipImageName))
        title.accept(value: tipTitle)
    }
    
    func viewLoaded() {
        viewedTrainingTips.storeViewedTrainingTip(viewedTrainingTip: ViewedTrainingTip(trainingTipId: trainingTipId, resourceId: resource.id, languageId: language.id))
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
    
    func buttonWithUrlTapped(url: String) {
        
        let exitLink = ExitLinkModel(
            screenName: getExitAnalyticsScreenName(),
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            url: url
        )
        
        renderedPageContext.navigation.buttonWithUrlTapped(url: url, exitLink: exitLink)
    }
    
    func tipPageWillAppear(page: Int, window: UIViewController, safeArea: UIEdgeInsets) -> MobileContentView? {
              
        guard page >= 0 && page < tipModel.pages.count else {
            return nil
        }
        
        return pageRenderer.recurseAndRender(
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
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: getTipPageAnalyticsScreenName(tipPage: page), siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
    }
}
