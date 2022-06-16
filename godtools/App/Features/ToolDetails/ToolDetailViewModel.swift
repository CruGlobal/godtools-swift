//
//  ToolDetailViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser
import RealmSwift

class ToolDetailViewModel: NSObject, ToolDetailViewModelType {
    
    private let resource: ResourceModel
    private let dataDownloader: InitialDataDownloader
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let translationDownloader: TranslationDownloader
    private let mobileContentParser: MobileContentParser
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let banner: ObservableValue<ToolDetailBannerType>
    let translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let name: ObservableValue<String> = ObservableValue(value: "")
    let totalViews: ObservableValue<String> = ObservableValue(value: "")
    let openToolTitle: ObservableValue<String> = ObservableValue(value: "")
    let unfavoriteTitle: ObservableValue<String> = ObservableValue(value: "")
    let favoriteTitle: ObservableValue<String> = ObservableValue(value: "")
    let hidesUnfavoriteButton: ObservableValue<Bool> = ObservableValue(value: true)
    let hidesFavoriteButton: ObservableValue<Bool> = ObservableValue(value: false)
    let learnToShareToolTitle: ObservableValue<String> = ObservableValue(value: "")
    let hidesLearnToShareToolButton: ObservableValue<Bool> = ObservableValue(value: true)
    let toolDetailsControls: ObservableValue<[ToolDetailControl]> = ObservableValue(value: [])
    let selectedDetailControl: ObservableValue<ToolDetailControl?> = ObservableValue(value: nil)
    let aboutDetails: ObservableValue<String> = ObservableValue(value: "")
    let languageDetails: ObservableValue<String> = ObservableValue(value: "")
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, dataDownloader: InitialDataDownloader, favoritedResourcesCache: FavoritedResourcesCache, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, translationDownloader: TranslationDownloader, mobileContentParser: MobileContentParser, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.translationDownloader = translationDownloader
        self.mobileContentParser = mobileContentParser
        self.analytics = analytics
        
        let bannerValue: ToolDetailBannerType
        
        if !resource.attrAboutOverviewVideoYoutube.isEmpty {
            
            let playsInFullScreen: Int = 0
            let playerParameters: [String: Any] = [Strings.YoutubePlayerParameters.playsInline.rawValue: playsInFullScreen]
            
            bannerValue = .youtube(videoId: resource.attrAboutOverviewVideoYoutube, playerParameters: playerParameters)
        }
        else if !resource.attrAboutBannerAnimation.isEmpty, let filePath = dataDownloader.attachmentsFileCache.getAttachmentFileUrl(attachmentId: resource.attrAboutBannerAnimation)?.path {
            
            let resource: AnimatedResource = .filepathJsonFile(filepath: filePath)
            let viewModel = AnimatedViewModel(animationDataResource: resource, autoPlay: true, loop: true)
            
            bannerValue = .animation(viewModel: viewModel)
        }
        else if let image = dataDownloader.attachmentsFileCache.getAttachmentBanner(attachmentId: resource.attrBannerAbout) {
            bannerValue = .image(image: image)
        }
        else {
            bannerValue = .empty
        }
        
        self.banner = ObservableValue(value: bannerValue)
                
        super.init()
        
        downloadResourceTranslation()
        
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
        
        let resourcesCache: ResourcesCache = dataDownloader.resourcesCache

        let toolName: String
        let toolAboutDetails: String
        let languageBundle: Bundle
        
        if let primaryLanguage = languageSettingsService.primaryLanguage.value, let primaryTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguage.id) {
            
            toolName = primaryTranslation.translatedName
            toolAboutDetails = primaryTranslation.translatedDescription
            languageBundle = localizationServices.bundleLoader.bundleForResource(resourceName: primaryLanguage.code) ?? Bundle.main
        }
        else if let englishTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageCode: "en") {
            
            toolName = englishTranslation.translatedName
            toolAboutDetails = englishTranslation.translatedDescription
            languageBundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
        }
        else {
            
            toolName = resource.name
            toolAboutDetails = resource.resourceDescription
            languageBundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
        }
        
        let languages: [LanguageModel] =  dataDownloader.resourcesCache.getResourceLanguages(resourceId: resource.id)
        let languageNames: [String] = languages.map({LanguageViewModel(language: $0, localizationServices: localizationServices).translatedLanguageName})
        let sortedLanguageNames: [String] = languageNames.sorted(by: { $0 < $1 })
        let languageDetailsValue: String = sortedLanguageNames.joined(separator: ", ")
        
        let numberOfLanguages: Int = languages.count
        
        name.accept(value: toolName)
        aboutDetails.accept(value: toolAboutDetails)
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
        
        languageDetails.accept(value: languageDetailsValue)
    }
    
    private var analyticsScreenName: String {
        return resource.abbreviation + "-tool-info"
    }
    
    private var siteSection: String {
        return resource.abbreviation
    }
    
    private var siteSubSection: String {
        return "tool-info"
    }
    
    private func downloadResourceTranslation() {
        
        let translationDownloader: TranslationDownloader = self.translationDownloader
        
        let resourceId: String = resource.id
        let languageId: String = languageSettingsService.primaryLanguage.value?.id ?? ""
        
        translationDownloader.fetchTranslationManifestAndDownloadIfNeeded(
            resourceId: resourceId,
            languageId: languageId,
            cache: { [weak self] (translationManifest: TranslationManifestData) in
                self?.handleTranslationManifestDownloaded(result: .success(translationManifest))
        },
            downloadStarted: {
                // download started
        }, downloadComplete: { [weak self] (result: Result<TranslationManifestData, TranslationDownloaderError>) in
            self?.handleTranslationManifestDownloaded(result: result)
        })
    }
    
    private func handleTranslationManifestDownloaded(result: Result<TranslationManifestData, TranslationDownloaderError>) {
        
        let hidesLearnToShareButton: Bool
                
        switch result {
        
        case .success(let translationManifest):
                        
            switch mobileContentParser.parse(translationManifestData: translationManifest) {
            
            case .success(let manifest):
                hidesLearnToShareButton = manifest.tips.isEmpty
            
            case .failure(let error):
                hidesLearnToShareButton = true
            }
        
        case .failure(let error):
            hidesLearnToShareButton = true
        }
        
        hidesLearnToShareToolButton.accept(value: hidesLearnToShareButton)
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: siteSection, siteSubSection: siteSubSection))
    }
    
    func openToolTapped() {
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: analyticsScreenName, actionName: AnalyticsConstants.ActionNames.aboutToolOpened, siteSection: siteSection, siteSubSection: siteSubSection, url: nil, data: [AnalyticsConstants.Keys.toolAboutOpened: 1]))
        flowDelegate?.navigate(step: .openToolTappedFromToolDetails(resource: resource))
    }
    
    func favoriteTapped() {
        favoritedResourcesCache.addToFavorites(resourceId: resource.id)
        //resourcesService.translationsServices.downloadAndCacheTranslations(resource: resource)
    }
    
    func unfavoriteTapped() {
        favoritedResourcesCache.removeFromFavorites(resourceId: resource.id)
    }
    
    func learnToShareToolTapped() {
        flowDelegate?.navigate(step: .learnToShareToolTappedFromToolDetails(resource: resource))
    }
    
    func detailControlTapped(detailControl: ToolDetailControl) {
        
        selectedDetailControl.accept(value: detailControl)
    }
    
    func urlTapped(url: URL) {
                
        let exitLink = ExitLinkModel(
            screenName: analyticsScreenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            url: url.absoluteString
        )
        
        flowDelegate?.navigate(step: .urlLinkTappedFromToolDetail(url: url, exitLink: exitLink))
    }
}
