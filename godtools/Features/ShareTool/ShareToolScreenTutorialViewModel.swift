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
    
    private weak var flowDelegate: FlowDelegate?
    
    let customViewBuilder: CustomViewBuilderType
    let tutorialItems: ObservableValue<[TutorialItem]> = ObservableValue(value: [])
    let skipTitle: String
    let continueTitle: String
    let shareLinkTitle: String
    
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, tutorialItemsProvider: TutorialItemProviderType) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.tutorialItemsProvider = tutorialItemsProvider
        self.customViewBuilder = ShareToolScreenCustomTutorialViewBuilder()
        self.skipTitle = localizationServices.stringForMainBundle(key: "navigationBar.navigationItem.skip")
        self.continueTitle = localizationServices.stringForMainBundle(key: "tutorial.continueButton.title.continue")
        self.shareLinkTitle = localizationServices.stringForMainBundle(key: "share_link")
        
        tutorialItems.accept(value: tutorialItemsProvider.tutorialItems)
    }
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromShareToolScreenTutorial)
    }
    
    func skipTapped() {
        
    }
    
    func pageDidChange(page: Int) {
        
    }
    
    func pageDidAppear(page: Int) {
        
    }
    
    func continueTapped() {
        
    }
    
    func shareLinkTapped() {
        flowDelegate?.navigate(step: .shareLinkTappedFromShareToolScreenTutorial)
    }
}
