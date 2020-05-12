//
//  TractViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TractViewModel: TractViewModelType {
    
    private let analytics: AnalyticsContainer
    private let toolOpenedAnalytics: ToolOpenedAnalytics
    
    let resource: DownloadedResource
    let primaryLanguage: Language
    let parallelLanguage: Language?
    let navTitle: ObservableValue<String> = ObservableValue(value: "God Tools")
    let hidesChooseLanguageControl: Bool
    let chooseLanguageControlPrimaryLanguageTitle: String
    let chooseLanguageControlParallelLanguageTitle: String
    let selectedLanguage: ObservableValue<Language?> = ObservableValue(value: nil)
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, resource: DownloadedResource, primaryLanguage: Language, parallelLanguage: Language?, analytics: AnalyticsContainer, toolOpenedAnalytics: ToolOpenedAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.primaryLanguage = primaryLanguage
        self.parallelLanguage = parallelLanguage?.code != primaryLanguage.code ? parallelLanguage : nil
        self.analytics = analytics
        self.toolOpenedAnalytics = toolOpenedAnalytics
        self.hidesChooseLanguageControl = self.parallelLanguage == nil
        
        chooseLanguageControlPrimaryLanguageTitle = primaryLanguage.localizedName()
        chooseLanguageControlParallelLanguageTitle = parallelLanguage?.localizedName() ?? ""
        selectedLanguage.accept(value: primaryLanguage)
    }
    
    func navHomeTapped() {
        flowDelegate?.navigate(step: .homeTappedFromTract)
    }
    
    func primaryLanguageTapped() {
        trackTappedLanguage(language: primaryLanguage)
    }
    
    func parallelLanguagedTapped() {
        
        guard let parallelLanguage = parallelLanguage else {
            return
        }
        
        trackTappedLanguage(language: parallelLanguage)
    }
    
    func viewLoaded() {
        
        toolOpenedAnalytics.trackFirstToolOpenedIfNeeded()
        toolOpenedAnalytics.trackToolOpened()
    }
    
    private func trackTappedLanguage(language: Language) {
        
        let data: [AnyHashable: String] = [
            AdobeAnalyticsConstants.Keys.parallelLanguageToggle: "",
            AdobeAnalyticsProperties.CodingKeys.contentLanguageSecondary.rawValue: language.code,
            AdobeAnalyticsProperties.CodingKeys.siteSection.rawValue: resource.code
        ]
        
        analytics.adobeAnalytics.trackAction(
            screenName: nil,
            actionName: AdobeAnalyticsConstants.Values.parallelLanguageToggle,
            data: data
        )
    }
}
