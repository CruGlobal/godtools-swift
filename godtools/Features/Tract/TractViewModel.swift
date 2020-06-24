//
//  TractViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TractViewModel: TractViewModelType {
    
    private let resource: ResourceModel
    private let primaryLanguage: LanguageModel
    private let parallelLanguage: LanguageModel?
    private let languageSettingsService: LanguageSettingsService
    private let viewsService: ViewsServiceType
    private let analytics: AnalyticsContainer
    private let toolOpenedAnalytics: ToolOpenedAnalytics
    private let primaryTractXmlResource: TractXmlResource
    private let parallelTractXmlResource: TractXmlResource?
    
    private var cachedPrimaryTractPages: [Int: TractPage] = Dictionary()
    private var cachedParallelTractPages: [Int: TractPage] = Dictionary()
    private var tractPage: Int = -1
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "God Tools")
    let navBarAttributes: TractNavBarAttributes
    let hidesChooseLanguageControl: Bool
    let chooseLanguageControlPrimaryLanguageTitle: String
    let chooseLanguageControlParallelLanguageTitle: String
    let selectedTractLanguage: ObservableValue<TractLanguage>
    let tractXmlPageItems: ObservableValue<[TractXmlPageItem]> = ObservableValue(value: [])
    let currentTractPageItemIndex: ObservableValue<AnimatableValue<Int>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, languageSettingsService: LanguageSettingsService, viewsService: ViewsServiceType, analytics: AnalyticsContainer, toolOpenedAnalytics: ToolOpenedAnalytics, tractPage: Int?) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.primaryLanguage = primaryLanguage
        self.parallelLanguage = parallelLanguage?.code != primaryLanguage.code ? parallelLanguage : nil
        self.languageSettingsService = languageSettingsService
        self.viewsService = viewsService
        self.analytics = analytics
        self.toolOpenedAnalytics = toolOpenedAnalytics
        
        // TODO: Implement ~Levi
        //primaryTractXmlResource = tractManager.loadResource(resource: resource, language: primaryLanguage)
        primaryTractXmlResource = TractXmlResource(pages: [], manifestProperties: ManifestProperties())
        
        if let parallelLanguage = self.parallelLanguage {
            // TODO: Implement. ~Levi
            //parallelTractXmlResource = tractManager.loadResource(resource: resource, language: parallelLanguage)
            parallelTractXmlResource = TractXmlResource(pages: [], manifestProperties: ManifestProperties())
        }
        else {
            parallelTractXmlResource = nil
        }
        
        let primaryManifest: ManifestProperties = primaryTractXmlResource.manifestProperties
        navBarAttributes = TractNavBarAttributes(
            navBarColor: primaryManifest.navbarColor ?? primaryManifest.primaryColor,
            navBarControlColor: primaryManifest.navbarControlColor ?? primaryManifest.primaryTextColor
        )
        
        // TODO: Implement. ~Levi
        //hidesChooseLanguageControl = !TractViewModel.parallelLanguageIsValid(resource: resource, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage)
        hidesChooseLanguageControl = true
        
        chooseLanguageControlPrimaryLanguageTitle = LanguageNameTranslationViewModel(language: primaryLanguage, languageSettingsService: languageSettingsService, shouldFallbackToPrimaryLanguageLocale: false).name
        
        let parallelLocalizedName: String
        if let parallelLanguage = parallelLanguage {
            parallelLocalizedName = LanguageNameTranslationViewModel(language: parallelLanguage, languageSettingsService: languageSettingsService, shouldFallbackToPrimaryLanguageLocale: false).name
        }
        else {
            parallelLocalizedName = ""
        }
        
        chooseLanguageControlParallelLanguageTitle = parallelLocalizedName
        
        selectedTractLanguage = ObservableValue(value: TractLanguage(languageType: .primary, language: primaryLanguage))
        
        _ = viewsService.addNewResourceViews(resourceIds: [resource.id])
        
        let startingTractPage: Int = tractPage ?? 0
        
        cacheTractPageIfNeeded(
            languageType: selectedTractLanguage.value.languageType,
            page: startingTractPage
        )
        
        loadTractXmlPages()
        
        setTractPage(
            page: startingTractPage,
            shouldSetCurrentToolPageItemIndex: true,
            animated: false
        )
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
                        
        cacheSurroundingTractPagesIfNeeded(
            languageType: selectedTractLanguage.value.languageType,
            page: page
        )
        
        resetTractPagesOutsideOfBuffer(
            buffer: 1,
            currentPage: page
        )
                        
        let previousToolPage: Int = tractPage
        
        self.tractPage = page
        
        if shouldSetCurrentToolPageItemIndex {
            currentTractPageItemIndex.accept(value: AnimatableValue(value: page, animated: animated))
        }
        
        if previousToolPage != page {
            
            analytics.pageViewedAnalytics.trackPageView(
                screenName: resource.abbreviation + "-" + String(page),
                siteSection: resource.abbreviation,
                siteSubSection: ""
            )
        }
    }
    
    static private func parallelLanguageIsValid(resource: DownloadedResource, primaryLanguage: Language, parallelLanguage: Language?) -> Bool {
                
        let parallelLanguageIsPrimaryLanguage: Bool = primaryLanguage.code == parallelLanguage?.code
        
        var parallelLanguageTranslationExists: Bool = false
        if let parallelLanguageCode = parallelLanguage?.code {
            for translation in resource.translations {
                if let languageCode = translation.language?.code {
                    if languageCode == parallelLanguageCode {
                        parallelLanguageTranslationExists = true
                        break
                    }
                }
            }
        }
        
        return !parallelLanguageIsPrimaryLanguage && parallelLanguageTranslationExists
    }
    
    var isRightToLeftLanguage: Bool {
        switch LanguageDirection.direction(language: primaryLanguage) {
        case .leftToRight:
            return false
        case .rightToLeft:
            return true
        }
    }
    
    var currentTractPage: Int {
        return tractPage
    }
    
    var primaryTractManifest: ManifestProperties {
        return primaryTractXmlResource.manifestProperties
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
                                
        switchFromParallelTractPageToPrimaryTractPage(page: tractPage)
        
        trackTappedLanguage(language: primaryLanguage)
                
        selectedTractLanguage.accept(value: TractLanguage(languageType: .primary, language: primaryLanguage))
    }
    
    func parallelLanguagedTapped() {
        
        guard let parallelLanguage = parallelLanguage else {
            return
        }
        
        switchFromPrimaryTractPageToParallelTractPage(page: tractPage)
                
        trackTappedLanguage(language: parallelLanguage)
                
        selectedTractLanguage.accept(value: TractLanguage(languageType: .parallel, language: parallelLanguage))
    }
    
    private func trackTappedLanguage(language: LanguageModel) {
        
        let data: [AnyHashable: String] = [
            AdobeAnalyticsConstants.Keys.parallelLanguageToggle: "",
            AdobeAnalyticsProperties.CodingKeys.contentLanguageSecondary.rawValue: language.code,
            AdobeAnalyticsProperties.CodingKeys.siteSection.rawValue: resource.abbreviation
        ]
        
        analytics.trackActionAnalytics.trackAction(
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
    
    // MARK: - Switching Between Primary and Parallel Tract Pages
    
    private func switchFromPrimaryTractPageToParallelTractPage(page: Int) {
               
        let cachedPrimaryTractPage: TractPage? = getCachedTractPage(
            languageType: .primary,
            page: page
        )
        
        let newParallelTractPage: TractPage? = buildTractPageForLanguage(
            languageType: .parallel,
            page: page,
            parallelTractPage: cachedPrimaryTractPage
        )
        
        if let newParallelTractPage = newParallelTractPage {
            
            cacheTractPage(
                languageType: .parallel,
                page: page,
                tractPage: newParallelTractPage
            )
        }
    }
    
    private func switchFromParallelTractPageToPrimaryTractPage(page: Int) {
        
        let cachedParallelTractPage: TractPage? = getCachedTractPage(
            languageType: .parallel,
            page: page
        )
        
        let newPrimaryTractPage: TractPage? = buildTractPageForLanguage(
            languageType: .primary,
            page: page,
            parallelTractPage: cachedParallelTractPage
        )
        
        if let newPrimaryTractPage = newPrimaryTractPage {
            
            cacheTractPage(
                languageType: .primary,
                page: page,
                tractPage: newPrimaryTractPage
            )
        }
    }
    
    // MARK: - Resetting Tract Pages
    
    private func resetTractPagesOutsideOfBuffer(buffer: Int, currentPage: Int) {
                
        resetTractPagesOutsideOfBuffer(languageType: .primary, buffer: buffer, currentPage: currentPage)
        
        resetTractPagesOutsideOfBuffer(languageType: .parallel, buffer: buffer, currentPage: currentPage)
    }
    
    private func resetTractPagesOutsideOfBuffer(languageType: TractLanguageType, buffer: Int, currentPage: Int) {
        
        let tractPagesCache: [Int: TractPage]
        
        switch languageType {
        case .primary:
            tractPagesCache = cachedPrimaryTractPages
        case .parallel:
            tractPagesCache = cachedParallelTractPages
        }
        
        let tractPageKeys: [Int] = Array(tractPagesCache.keys)
                
        for key in tractPageKeys {
            let distance: Int = abs(currentPage - key)
            if distance > buffer {
                tractPagesCache[key]?.reset()
            }
        }
    }
    
    // MARK: - Building New Tract Pages
    
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
            tractManifest: primaryTractXmlResource.manifestProperties,
            parallelTractPage: parallelTractPage
        )
    }
    
    private func buildParallelTractPage(page: Int, parallelTractPage: TractPage?) -> TractPage? {
        
        if let parallelLanguage = parallelLanguage, let parallelTractXmlResource = parallelTractXmlResource {
            
            return buildTractPage(
                page: page,
                language: parallelLanguage,
                tractXmlResource: parallelTractXmlResource,
                tractManifest: parallelTractXmlResource.manifestProperties,
                parallelTractPage: parallelTractPage
            )
        }
        
        return nil
    }
    
    private func buildTractPage(page: Int, language: LanguageModel, tractXmlResource: TractXmlResource, tractManifest: ManifestProperties, parallelTractPage: TractPage?) -> TractPage? {
        
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
    
    // MARK: - Cacheing Tract Pages
    
    private func cacheSurroundingTractPagesIfNeeded(languageType: TractLanguageType, page: Int) {
                
        cacheTractPageIfNeeded(languageType: languageType, page: page - 2)
        cacheTractPageIfNeeded(languageType: languageType, page: page - 1)
        cacheTractPageIfNeeded(languageType: languageType, page: page + 1)
        cacheTractPageIfNeeded(languageType: languageType, page: page + 2)
    }
    
    private func getTractPageCacheDictionary(languageType: TractLanguageType) -> [Int: TractPage] {
        switch languageType {
        case .primary:
            return cachedPrimaryTractPages
        case .parallel:
            return cachedParallelTractPages
        }
    }
    
    private func cacheTractPage(languageType: TractLanguageType, page: Int, tractPage: TractPage) {
        
        switch languageType {
        case .primary:
            cachedPrimaryTractPages[page] = tractPage
        case .parallel:
            cachedParallelTractPages[page] = tractPage
        }
    }
    
    private func getCachedTractPage(languageType: TractLanguageType, page: Int) -> TractPage? {
        return getTractPageCacheDictionary(languageType: languageType)[page]
    }
    
    private func cacheTractPageIfNeeded(languageType: TractLanguageType, page: Int) {
                            
        let cachedTract: TractPage? = getCachedTractPage(
            languageType: languageType,
            page: page
        )
        
        let tractIsCached: Bool = cachedTract != nil
        
        if !tractIsCached, let tractPage = buildTractPageForLanguage(languageType: languageType, page: page, parallelTractPage: nil) {
                        
            cacheTractPage(
                languageType: languageType,
                page: page,
                tractPage: tractPage
            )
        }
    }
    
    func getTractPage(page: Int) -> TractPage? {
            
        let selectedLanguageType: TractLanguageType = selectedTractLanguage.value.languageType
        
        let cachedTractPage: TractPage? = getCachedTractPage(
            languageType: selectedLanguageType,
            page: page
        )
        
        if let cachedTractPage = cachedTractPage {
            
            return cachedTractPage
        }
        
        let newTractPage: TractPage? = buildTractPageForLanguage(
            languageType: selectedLanguageType,
            page: page,
            parallelTractPage: nil
        )
        
        if let newTractPage = newTractPage {
            
            cacheTractPage(
                languageType: selectedLanguageType,
                page: page,
                tractPage: newTractPage
            )
            
            return newTractPage
        }
        
        return nil
    }
}
