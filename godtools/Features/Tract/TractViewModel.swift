//
//  TractViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TractViewModel: TractViewModelType {
    
    private let tractManager: TractManager
    private let analytics: AnalyticsContainer
    private let toolOpenedAnalytics: ToolOpenedAnalytics
    private let primaryTractXmlResource: TractXmlResource
    private let parallelTractXmlResource: TractXmlResource?
    
    let resource: DownloadedResource
    let primaryLanguage: Language
    let parallelLanguage: Language?
    let navTitle: ObservableValue<String> = ObservableValue(value: "God Tools")
    let navBarAttributes: ToolNavBarAttributes
    let hidesChooseLanguageControl: Bool
    let chooseLanguageControlPrimaryLanguageTitle: String
    let chooseLanguageControlParallelLanguageTitle: String
    let selectedLanguage: ObservableValue<Language>
    let toolManifest: ManifestProperties
    let toolXmlPages: ObservableValue<[XMLPage]> = ObservableValue(value: [])
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, resource: DownloadedResource, primaryLanguage: Language, parallelLanguage: Language?, tractManager: TractManager, analytics: AnalyticsContainer, toolOpenedAnalytics: ToolOpenedAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.primaryLanguage = primaryLanguage
        self.parallelLanguage = parallelLanguage?.code != primaryLanguage.code ? parallelLanguage : nil
        self.tractManager = tractManager
        self.analytics = analytics
        self.toolOpenedAnalytics = toolOpenedAnalytics
        primaryTractXmlResource = tractManager.loadResource(resource: resource, language: primaryLanguage)
        if let parallelLanguage = self.parallelLanguage {
            parallelTractXmlResource = tractManager.loadResource(resource: resource, language: parallelLanguage)
        }
        else {
            parallelTractXmlResource = nil
        }
        let primaryManifest: ManifestProperties = primaryTractXmlResource.manifestProperties
        navBarAttributes = ToolNavBarAttributes(
            navBarColor: primaryManifest.navbarColor ?? primaryManifest.primaryColor,
            navBarControlColor: primaryManifest.navbarControlColor ?? primaryManifest.primaryTextColor
        )
        hidesChooseLanguageControl = self.parallelLanguage == nil
        chooseLanguageControlPrimaryLanguageTitle = primaryLanguage.localizedName()
        chooseLanguageControlParallelLanguageTitle = parallelLanguage?.localizedName() ?? ""
        selectedLanguage = ObservableValue(value: primaryLanguage)
        toolManifest = primaryTractXmlResource.manifestProperties
        toolXmlPages.accept(value: primaryTractXmlResource.pages)
    }
    
    var isRightToLeftLanguage: Bool {
        return primaryLanguage.isRightToLeft()
    }
    
    func pageViewed() {
        
        // TODO: Get current page number ~Levi
        let pageNumber: Int = 0
        
        // TODO: Call when a new page within the tool is tapped. ~Levi
        
        analytics.pageViewedAnalytics.trackPageView(
            screenName: resource.code + "-" + String(pageNumber),
            siteSection: resource.code,
            siteSubSection: ""
        )
    }
    
    func navHomeTapped() {
        flowDelegate?.navigate(step: .homeTappedFromTract)
    }
    
    func shareTapped() {
        // TODO: Set pageNumber for current page in tool. ~Levi
        flowDelegate?.navigate(step: .shareTappedFromTract(resource: resource, language: selectedLanguage.value, pageNumber: 0))
    }
    
    func primaryLanguageTapped() {
                
        trackTappedLanguage(language: primaryLanguage)
        
        selectedLanguage.accept(value: primaryLanguage)
        
        toolXmlPages.accept(value: primaryTractXmlResource.pages)
    }
    
    func parallelLanguagedTapped() {
        
        guard let parallelLanguage = parallelLanguage else {
            return
        }
                
        trackTappedLanguage(language: parallelLanguage)
        
        selectedLanguage.accept(value: parallelLanguage)
        
        if let parallelTractXmlResource = self.parallelTractXmlResource {
            toolXmlPages.accept(value: parallelTractXmlResource.pages)
        }
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
