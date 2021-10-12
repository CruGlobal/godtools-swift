//
//  ShareToolScreenTutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ShareToolScreenTutorialViewModel: ShareToolScreenTutorialViewModelType {
    
    private let localizationServices: LocalizationServices
    private let tutorialItemsProvider: TutorialItemProviderType
    private let shareToolScreenTutorialNumberOfViewsCache: ShareToolScreenTutorialNumberOfViewsCache
    private let resource: ResourceModel
    
    private weak var flowDelegate: FlowDelegate?
    
    let customViewBuilder: CustomViewBuilderType
    let tutorialItems: ObservableValue<[TutorialItemType]> = ObservableValue(value: [])
    let skipTitle: String
    let continueTitle: String
    let shareLinkTitle: String
    
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, tutorialItemsProvider: TutorialItemProviderType, shareToolScreenTutorialNumberOfViewsCache: ShareToolScreenTutorialNumberOfViewsCache, resource: ResourceModel) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.tutorialItemsProvider = tutorialItemsProvider
        self.shareToolScreenTutorialNumberOfViewsCache = shareToolScreenTutorialNumberOfViewsCache
        self.resource = resource
        self.customViewBuilder = ShareToolScreenCustomTutorialViewBuilder()
        self.skipTitle = localizationServices.stringForMainBundle(key: "navigationBar.navigationItem.skip")
        self.continueTitle = localizationServices.stringForMainBundle(key: "tutorial.continueButton.title.continue")
        self.shareLinkTitle = localizationServices.stringForMainBundle(key: "share_link")
        
        tutorialItems.accept(value: tutorialItemsProvider.tutorialItems)
    }
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromShareToolScreenTutorial)
    }
    
    func shareLinkTapped() {
        shareToolScreenTutorialNumberOfViewsCache.tutorialViewed(resource: resource)
        flowDelegate?.navigate(step: .shareLinkTappedFromShareToolScreenTutorial)
    }
}
