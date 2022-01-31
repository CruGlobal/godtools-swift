//
//  ChooseYourOwnAdventureViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ChooseYourOwnAdventureViewModel: MobileContentPagesViewModel, ChooseYourOwnAdventureViewModelType {
    
    private let localizationServiecs: LocalizationServices
    
    required init(flowDelegate: FlowDelegate, renderers: [MobileContentRendererType], primaryLanguage: LanguageModel, page: Int?, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, localizationServiecs: LocalizationServices) {
        
        self.localizationServiecs = localizationServiecs
        
        super.init(flowDelegate: flowDelegate, renderers: renderers, primaryLanguage: primaryLanguage, page: page, mobileContentEventAnalytics: mobileContentEventAnalytics)
    }
    
    required init(flowDelegate: FlowDelegate, renderers: [MobileContentRendererType], primaryLanguage: LanguageModel, page: Int?, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking) {
        fatalError("init(flowDelegate:renderers:primaryLanguage:page:mobileContentEventAnalytics:) has not been implemented")
    }
    
    func getNavBarLanguageTitles() -> [String] {
        return renderers.map({ LanguageViewModel(language: $0.language, localizationServices: localizationServiecs).translatedLanguageName })
    }
    
    func navBackTapped() {
        
        let isFirstPage: Bool = currentPage == 0
        
        if isFirstPage {
            flowDelegate?.navigate(step: FlowStep.homeTappedFromTool(isScreenSharing: false))
        }
    }
    
    func languageTapped(index: Int) {
        
    }
}
