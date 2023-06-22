//
//  ShareToolScreenTutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ShareToolScreenTutorialViewModel {
    //TODO: re-implement this tutorial using TutorialPagerViewModel
    
    private let localizationServices: LocalizationServices
    private let tutorialItemsProvider: ShareToolScreenTutorialItemProvider
    private let shareToolScreenTutorialNumberOfViewsCache: ShareToolScreenTutorialNumberOfViewsCache
    private let resource: ResourceModel
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let analyticsContainer: AnalyticsContainer
    private let tutorialVideoAnalytics: TutorialVideoAnalytics
    
    private weak var flowDelegate: FlowDelegate?
    
    let customViewBuilder: CustomViewBuilderType
    let tutorialItems: ObservableValue<[TutorialItemType]> = ObservableValue(value: [])
    let skipTitle: String
    let continueTitle: String
    let shareLinkTitle: String
    
    init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, tutorialItemsProvider: ShareToolScreenTutorialItemProvider, shareToolScreenTutorialNumberOfViewsCache: ShareToolScreenTutorialNumberOfViewsCache, resource: ResourceModel, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, analyticsContainer: AnalyticsContainer, tutorialVideoAnalytics: TutorialVideoAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.tutorialItemsProvider = tutorialItemsProvider
        self.shareToolScreenTutorialNumberOfViewsCache = shareToolScreenTutorialNumberOfViewsCache
        self.resource = resource
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.analyticsContainer = analyticsContainer
        self.tutorialVideoAnalytics = tutorialVideoAnalytics
        self.customViewBuilder = ShareToolScreenCustomTutorialViewBuilder()
        self.skipTitle = localizationServices.stringForMainBundle(key: "navigationBar.navigationItem.skip")
        self.continueTitle = localizationServices.stringForMainBundle(key: "tutorial.continueButton.title.continue")
        self.shareLinkTitle = localizationServices.stringForMainBundle(key: "share_link")
        
        tutorialItems.accept(value: tutorialItemsProvider.tutorialItems)
    }
    
    private var analyticsScreenName: String {
        return "shareToolScreen"
    }
    
    func getTutorialItemViewModel(index: Int) -> TutorialCellViewModelType {
                
        return TutorialCellViewModel(
            item: tutorialItems.value[index],
            customViewBuilder: customViewBuilder,
            tutorialVideoAnalytics: tutorialVideoAnalytics,
            analyticsScreenName: analyticsScreenName,
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase
        )
    }
}

// MARK: - Inputs

extension ShareToolScreenTutorialViewModel {
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromShareToolScreenTutorial)
    }
    
    func shareLinkTapped() {
        shareToolScreenTutorialNumberOfViewsCache.tutorialViewed(resource: resource)
        flowDelegate?.navigate(step: .shareLinkTappedFromShareToolScreenTutorial)
    }
}
