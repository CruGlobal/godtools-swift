//
//  ToolDetailViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import RealmSwift

class ToolDetailViewModel: NSObject, ToolDetailViewModelType {
    
    private let resource: ResourceModel
    private let dataDownloader: InitialDataDownloader
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let fetchLanguageTranslationViewModel: FetchLanguageTranslationViewModel
    private let translateLanguageNameViewModel: TranslateLanguageNameViewModel
    private let analytics: AnalyticsContainer
    private let exitLinkAnalytics: ExitLinkAnalytics
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let topToolDetailMedia: ObservableValue<ToolDetailMedia?> = ObservableValue(value: nil)
    let hidesBannerImage: ObservableValue<Bool> = ObservableValue(value: false)
    let hidesYoutubePlayer: ObservableValue<Bool> = ObservableValue(value: false)
    let translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let name: ObservableValue<String> = ObservableValue(value: "")
    let totalViews: ObservableValue<String> = ObservableValue(value: "")
    let openToolTitle: ObservableValue<String> = ObservableValue(value: "")
    let unfavoriteTitle: ObservableValue<String> = ObservableValue(value: "")
    let favoriteTitle: ObservableValue<String> = ObservableValue(value: "")
    let hidesUnfavoriteButton: ObservableValue<Bool> = ObservableValue(value: true)
    let hidesFavoriteButton: ObservableValue<Bool> = ObservableValue(value: false)
    let toolDetailsControls: ObservableValue<[ToolDetailControl]> = ObservableValue(value: [])
    let selectedDetailControl: ObservableValue<ToolDetailControl?> = ObservableValue(value: nil)
    let aboutDetails: ObservableValue<String> = ObservableValue(value: "")
    let languageDetails: ObservableValue<String> = ObservableValue(value: "")
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, dataDownloader: InitialDataDownloader, favoritedResourcesCache: FavoritedResourcesCache, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, fetchLanguageTranslationViewModel: FetchLanguageTranslationViewModel, analytics: AnalyticsContainer, exitLinkAnalytics: ExitLinkAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.fetchLanguageTranslationViewModel = fetchLanguageTranslationViewModel
        self.translateLanguageNameViewModel = TranslateLanguageNameViewModel(
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            shouldFallbackToPrimaryLanguageLocale: true
        )
        self.analytics = analytics
        self.exitLinkAnalytics = exitLinkAnalytics
                
        super.init()
        
        if !resource.attrAboutOverviewVideoYoutube.isEmpty {
            hidesBannerImage.accept(value: true)
            hidesYoutubePlayer.accept(value: false)
            topToolDetailMedia.accept(value: ToolDetailMedia(bannerImage: nil, youtubePlayerId: resource.attrAboutOverviewVideoYoutube))
        }
        else {
            hidesBannerImage.accept(value: false)
            hidesYoutubePlayer.accept(value: true)
            let toolDetailImage: UIImage? = dataDownloader.attachmentsFileCache.getAttachmentBanner(attachmentId: resource.attrBannerAbout)
            topToolDetailMedia.accept(value: ToolDetailMedia(bannerImage: toolDetailImage, youtubePlayerId: ""))
        }
        
        reloadFavorited()
        reloadToolDetails()
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        favoritedResourcesCache.resourceFavorited.removeObserver(self)
        favoritedResourcesCache.resourceUnfavorited.removeObserver(self)
    }
    
    private func setupBinding() {
        
        favoritedResourcesCache.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadFavorited()
            }
        }
        
        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadFavorited()
            }
        }
    }
    
    private func reloadFavorited() {
                
        if favoritedResourcesCache.isFavorited(resourceId: resource.id) {
            hidesFavoriteButton.accept(value: true)
            hidesUnfavoriteButton.accept(value: false)
        }
        else {
            hidesFavoriteButton.accept(value: false)
            hidesUnfavoriteButton.accept(value: true)
        }
    }
    
    private func reloadToolDetails() {
        
        let primaryLanguageId: String = languageSettingsService.primaryLanguage.value?.id ?? ""
        
        let primaryTranslationResult: FetchLanguageTranslationResult = fetchLanguageTranslationViewModel.getLanguageTranslation(
            resourceId: resource.id,
            languageId: primaryLanguageId,
            supportedFallbackTypes: [.englishLanguage]
        )
        
        let languages: [LanguageModel] =  dataDownloader.resourcesCache.getResourceLanguages(resourceId: resource.id)
        
        let languageBundle: Bundle = localizationServices.bundleForResourceElseFallbackBundle(resourceName: languageSettingsService.primaryLanguage.value?.code ?? "")
        
        if let preferredTranslation = primaryTranslationResult.translation {
            name.accept(value: preferredTranslation.translatedName)
            aboutDetails.accept(value: preferredTranslation.translatedDescription)
        }
        else {
            name.accept(value: resource.name)
            aboutDetails.accept(value: resource.resourceDescription)
        }
        
        let languageNames: [String] = languages.map({$0.translatedName(translateLanguageNameViewModel: translateLanguageNameViewModel)})
        let sortedLanguageNames: String = languageNames.sorted(by: { $0 < $1 }).joined(separator: ", ")
        
        let numberOfLanguages: Int = languages.count
        
        totalViews.accept(value: String.localizedStringWithFormat(localizationServices.stringForBundle(bundle: languageBundle, key: "total_views"), resource.totalViews))
        openToolTitle.accept(value: localizationServices.stringForBundle(bundle: languageBundle, key: "toolinfo_opentool"))
        unfavoriteTitle.accept(value: localizationServices.stringForBundle(bundle: languageBundle, key: "remove_from_favorites"))
        favoriteTitle.accept(value: localizationServices.stringForBundle(bundle: languageBundle, key: "add_to_favorites"))
        
        // tool details
        let aboutDetailsControl = ToolDetailControl(
            id: "about",
            title: localizationServices.stringForBundle(bundle: languageBundle, key: "about"),
            controlId: .about
        )
        
        let languageDetailsControl = ToolDetailControl(
            id: "language",
            title: String.localizedStringWithFormat(localizationServices.stringForBundle(bundle: languageBundle, key: "total_languages"), numberOfLanguages),
            controlId: .languages
        )
        toolDetailsControls.accept(value: [aboutDetailsControl, languageDetailsControl])
        selectedDetailControl.accept(value: aboutDetailsControl)
        
        languageDetails.accept(value: sortedLanguageNames)
    }
    
    private var analyticsScreenName: String {
        return resource.abbreviation + "-" + "tool-info"
    }
    
    private var siteSection: String {
        return resource.abbreviation
    }
    
    private var siteSubSection: String {
        return ""
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(screenName: analyticsScreenName, siteSection: siteSection, siteSubSection: siteSubSection)
    }
    
    func openToolTapped() {
        analytics.trackActionAnalytics.trackAction(screenName: analyticsScreenName, actionName: "About Tool Open Button", data: ["cru.tool_about_button": 1])
        flowDelegate?.navigate(step: .openToolTappedFromToolDetails(resource: resource))
    }
    
    func favoriteTapped() {
        favoritedResourcesCache.addToFavorites(resourceId: resource.id)
        //resourcesService.translationsServices.downloadAndCacheTranslations(resource: resource)
    }
    
    func unfavoriteTapped() {
        favoritedResourcesCache.removeFromFavorites(resourceId: resource.id)
    }
    
    func detailControlTapped(detailControl: ToolDetailControl) {
        
        selectedDetailControl.accept(value: detailControl)
    }
    
    func urlTapped(url: URL) {
                
        exitLinkAnalytics.trackExitLink(
            screenName: analyticsScreenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            url: url
        )
        
        flowDelegate?.navigate(step: .urlLinkTappedFromToolDetail(url: url))
    }
}
