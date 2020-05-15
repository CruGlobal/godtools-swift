//
//  TractViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TractViewModel: TractViewModelType {
    
    private var tractPageCache: TractPageCache = TractPageCache()
    private let tractManager: TractManager
    private let analytics: AnalyticsContainer
    private let toolOpenedAnalytics: ToolOpenedAnalytics
    private let primaryTractXmlResource: TractXmlResource
    private let parallelTractXmlResource: TractXmlResource?
    
    private var tractPage: Int = -1
    
    let resource: DownloadedResource
    let primaryLanguage: Language
    let parallelLanguage: Language?
    let navTitle: ObservableValue<String> = ObservableValue(value: "God Tools")
    let navBarAttributes: TractNavBarAttributes
    let hidesChooseLanguageControl: Bool
    let chooseLanguageControlPrimaryLanguageTitle: String
    let chooseLanguageControlParallelLanguageTitle: String
    let selectedTractLanguage: ObservableValue<TractLanguage>
    let tractManifest: ManifestProperties
    let tractXmlPageItems: ObservableValue<[TractXmlPageItem]> = ObservableValue(value: [])
    let currentTractPageItemIndex: ObservableValue<AnimatableValue<Int>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, resource: DownloadedResource, primaryLanguage: Language, parallelLanguage: Language?, tractManager: TractManager, analytics: AnalyticsContainer, toolOpenedAnalytics: ToolOpenedAnalytics, tractPage: Int?) {
        
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
        navBarAttributes = TractNavBarAttributes(
            navBarColor: primaryManifest.navbarColor ?? primaryManifest.primaryColor,
            navBarControlColor: primaryManifest.navbarControlColor ?? primaryManifest.primaryTextColor
        )
        hidesChooseLanguageControl = self.parallelLanguage == nil
        chooseLanguageControlPrimaryLanguageTitle = primaryLanguage.localizedName()
        chooseLanguageControlParallelLanguageTitle = parallelLanguage?.localizedName() ?? ""
        selectedTractLanguage = ObservableValue(value: TractLanguage(languageType: .primary, language: primaryLanguage))
        tractManifest = primaryTractXmlResource.manifestProperties
        
        let startingTractPage: Int = tractPage ?? 0
        
        cacheTractPageIfNeeded(page: startingTractPage)
        
        loadTractXmlPages()
        
        setTractPage(page: startingTractPage, shouldSetCurrentToolPageItemIndex: true, animated: false)
    }
    
    private func loadTractXmlPages() {
        
        var tractItems: [TractXmlPageItem] = Array()
        
        for index in 0 ..< primaryTractXmlResource.pages.count {
            
            let primaryPage: XMLPage = primaryTractXmlResource.pages[index]
            let parallelPage: XMLPage?
            
            if let parallelTractXmlResource = parallelTractXmlResource, index >= 0 && index < parallelTractXmlResource.pages.count {
                parallelPage = parallelTractXmlResource.pages[index]
            }
            else {
                parallelPage = nil
            }
            
            tractItems.append(TractXmlPageItem(primaryXmlPage: primaryPage, parallelXmlPage: parallelPage))
        }
        
        tractXmlPageItems.accept(value: tractItems)
    }
    
    private func setTractPage(page: Int, shouldSetCurrentToolPageItemIndex: Bool, animated: Bool) {
        
        guard page >= 0 && page < tractXmlPageItems.value.count else {
            return
        }
                
        cacheTractPageIfNeeded(page: page - 2)
        cacheTractPageIfNeeded(page: page - 1)
        cacheTractPageIfNeeded(page: page + 1)
        cacheTractPageIfNeeded(page: page + 2)
        tractPageCache.deleteTractPagesOutsideBuffer(buffer: 2, page: page)
        
        let previousToolPage: Int = tractPage
        
        self.tractPage = page
        
        if shouldSetCurrentToolPageItemIndex {
            currentTractPageItemIndex.accept(value: AnimatableValue(value: page, animated: animated))
        }
        
        if previousToolPage != page {
            
            analytics.pageViewedAnalytics.trackPageView(
                screenName: resource.code + "-" + String(page),
                siteSection: resource.code,
                siteSubSection: ""
            )
        }
    }
    
    var isRightToLeftLanguage: Bool {
        return primaryLanguage.isRightToLeft()
    }
    
    var currentTractPage: Int {
        return tractPage
    }
    
    var primaryTractPages: [XMLPage] {
        return primaryTractXmlResource.pages
    }
    
    func navHomeTapped() {
        flowDelegate?.navigate(step: .homeTappedFromTract)
    }
    
    func shareTapped() {
        flowDelegate?.navigate(step: .shareTappedFromTract(resource: resource, language: selectedTractLanguage.value.language, pageNumber: tractPage))
    }
    
    func primaryLanguageTapped() {
                
        refreshTractPageForParallelLanguage(languageType: .parallel, page: tractPage)
        
        trackTappedLanguage(language: primaryLanguage)
                
        selectedTractLanguage.accept(value: TractLanguage(languageType: .primary, language: primaryLanguage))
    }
    
    func parallelLanguagedTapped() {
        
        guard let parallelLanguage = parallelLanguage else {
            return
        }
        
        refreshTractPageForParallelLanguage(languageType: .primary, page: tractPage)
                
        trackTappedLanguage(language: parallelLanguage)
                
        selectedTractLanguage.accept(value: TractLanguage(languageType: .parallel, language: parallelLanguage))
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
    
    func viewLoaded() {
        
        toolOpenedAnalytics.trackFirstToolOpenedIfNeeded()
        toolOpenedAnalytics.trackToolOpened()
    }
    
    func didScrollToTractPage(page: Int) {
                
        setTractPage(page: page, shouldSetCurrentToolPageItemIndex: false, animated: false)
    }
    
    func navigateToNextPageTapped() {
        let nextPage: Int = tractPage + 1
        if nextPage < tractXmlPageItems.value.count {
            setTractPage(page: nextPage, shouldSetCurrentToolPageItemIndex: true, animated: true)
        }
    }
    
    func navigateToPreviousPageTapped() {
        let previousPage: Int = tractPage - 1
        if previousPage > 0 {
            setTractPage(page: previousPage, shouldSetCurrentToolPageItemIndex: true, animated: true)
        }
    }
    
    func navigateToPageTapped(page: Int) {
        setTractPage(page: page, shouldSetCurrentToolPageItemIndex: true, animated: true)
    }
    
    func sendEmailTapped(subject: String?, message: String?, isHtml: Bool?) {
        flowDelegate?.navigate(step: .sendEmailTappedFromTract(subject: subject ?? "", message: message ?? "", isHtml: isHtml ?? false))
    }
    
    // MARK: - Tract Pages
    
    private func buildTractPageForCurrentLanguage(page: Int, parallelTractPage: TractPage?) -> TractPage? {
        
        return buildTractPageForLanguage(languageType: selectedTractLanguage.value.languageType, page: page, parallelTractPage: parallelTractPage)
    }
    
    private func buildTractPageForLanguage(languageType: TractLanguageType, page: Int, parallelTractPage: TractPage?) -> TractPage? {
        
        switch languageType {
        case .primary:
            return buildPrimaryTractPage(page: page, parallelTractPage: parallelTractPage)
        case .parallel:
            return buildParallelTractPage(page: page, parallelTractPage: parallelTractPage)
        }
    }
    
    private func buildPrimaryTractPage(page: Int, parallelTractPage: TractPage?) -> TractPage? {
        
        return buildTractPage(
            page: page,
            language: primaryLanguage,
            tractXmlResource: primaryTractXmlResource,
            parallelTractPage: parallelTractPage
        )
    }
    
    private func buildParallelTractPage(page: Int, parallelTractPage: TractPage?) -> TractPage? {
        
        if let parallelLanguage = parallelLanguage, let parallelTractXmlResource = parallelTractXmlResource {
            
            return buildTractPage(
                page: page,
                language: parallelLanguage,
                tractXmlResource: parallelTractXmlResource,
                parallelTractPage: parallelTractPage
            )
        }
        
        return nil
    }
    
    private func buildTractPage(page: Int, language: Language, tractXmlResource: TractXmlResource, parallelTractPage: TractPage?) -> TractPage? {
        
        let pages: [XMLPage] = tractXmlResource.pages
        
        if page >= 0 && page < pages.count {
            
            let xmlPage: XMLPage = pages[page]
            
            let config = TractConfigurations()
            config.defaultTextAlignment = .left
            config.pagination = xmlPage.pagination
            config.language = language
            config.resource = resource
            
            let tractPage = TractPage(
                startWithData: xmlPage.pageContent(),
                height: UIScreen.main.bounds.size.height,
                manifestProperties: tractManifest,
                configurations: config,
                parallelElement: parallelTractPage
            )
            
            return tractPage
        }
        
        return nil
    }
    
    private func refreshTractPageForParallelLanguage(languageType: TractLanguageType, page: Int) {
        
        let cachedTractPage: TractPage? = tractPageCache.getTractPage(type: languageType, page: page)
        
        let oppositeLanguage: TractLanguageType
        
        switch languageType {
        case .primary:
            oppositeLanguage = .parallel
        case .parallel:
            oppositeLanguage = .primary
        }
        
        tractPageCache.deleteTractPage(type: oppositeLanguage, page: page)
        
        if let tractPage = buildTractPageForLanguage(languageType: oppositeLanguage, page: page, parallelTractPage: cachedTractPage) {
            tractPageCache.cacheTractPage(type: oppositeLanguage, page: page, tractPage: tractPage)
        }
    }
    
    private func cacheTractPageIfNeeded(page: Int) {
                    
        let cachedTract: TractPage? = tractPageCache.getTractPage(type: selectedTractLanguage.value.languageType, page: page)
        let tractIsCached: Bool = cachedTract != nil
        
        if !tractIsCached, let tractPage = buildTractPageForCurrentLanguage(page: page, parallelTractPage: nil) {
                        
            tractPageCache.cacheTractPage(type: selectedTractLanguage.value.languageType, page: page, tractPage: tractPage)
        }
    }
    
    func getTractPage(page: Int) -> TractPage? {
                
        if let cachedTractPage = tractPageCache.getTractPage(type: selectedTractLanguage.value.languageType, page: page) {
            return cachedTractPage
        }
        else if let tractPage = buildTractPageForCurrentLanguage(page: page, parallelTractPage: nil) {
            tractPageCache.cacheTractPage(type: selectedTractLanguage.value.languageType, page: page, tractPage: tractPage)
            return tractPage
        }
        
        return nil
    }
}
