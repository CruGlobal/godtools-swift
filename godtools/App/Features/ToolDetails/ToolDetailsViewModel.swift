//
//  ToolDetailsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class ToolDetailsViewModel: NSObject, ObservableObject {
    
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let analytics: AnalyticsContainer
    private let getToolTranslationsUseCase: GetToolTranslationsUseCase
    private let languagesRepository: LanguagesRepository
    private let getToolVersionsUseCase: GetToolVersionsUseCase
    private let bannerImageRepository: ResourceBannerImageRepository
    private let segmentTypes: [ToolDetailsSegmentType] = [.about, .versions]
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var mediaType: ToolDetailsMediaType = .empty
    @Published var name: String = ""
    @Published var totalViews: String = ""
    @Published var openToolButtonTitle: String = ""
    @Published var learnToShareToolButtonTitle: String = ""
    @Published var addToFavoritesButtonTitle: String = ""
    @Published var removeFromFavoritesButtonTitle: String = ""
    @Published var hidesLearnToShareToolButton: Bool = true
    @Published var isFavorited: Bool = false
    @Published var segments: [String] = Array()
    @Published var selectedSegment: ToolDetailsSegmentType = .about
    @Published var aboutDetails: String = ""
    @Published var versionsMessage: String = ""
    @Published var toolVersions: [ToolVersionDomainModel] = Array()
    @Published var selectedToolVersion: ToolVersionDomainModel?
    
    init(flowDelegate: FlowDelegate, resource: ResourceModel, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritedResourcesCache: FavoritedResourcesCache, analytics: AnalyticsContainer, getToolTranslationsUseCase: GetToolTranslationsUseCase, languagesRepository: LanguagesRepository, getToolVersionsUseCase: GetToolVersionsUseCase, bannerImageRepository: ResourceBannerImageRepository) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritedResourcesCache = favoritedResourcesCache
        self.analytics = analytics
        self.getToolTranslationsUseCase = getToolTranslationsUseCase
        self.languagesRepository = languagesRepository
        self.getToolVersionsUseCase = getToolVersionsUseCase
        self.bannerImageRepository = bannerImageRepository
        self.versionsMessage = localizationServices.stringForMainBundle(key: "toolDetails.versions.message")
        
        super.init()
        
        reloadToolDetails(resource: resource)
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        favoritedResourcesCache.resourceFavorited.removeObserver(self)
        favoritedResourcesCache.resourceUnfavorited.removeObserver(self)
    }
    
    private var resource: ResourceModel {
        didSet {
            reloadToolDetails(resource: resource)
        }
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
    
    private func setupBinding() {
        
        favoritedResourcesCache.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadFavorited(resourceId: resourceId)
            }
        }
        
        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadFavorited(resourceId: resourceId)
            }
        }
    }
    
    private func reloadToolDetails(resource: ResourceModel) {
        
        let resourcesCache: ResourcesCache = dataDownloader.resourcesCache

        let nameValue: String
        let aboutDetailsValue: String
        let languageBundle: Bundle
        
        if let primaryLanguage = languageSettingsService.primaryLanguage.value, let primaryTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguage.id) {
            
            nameValue = primaryTranslation.translatedName
            aboutDetailsValue = primaryTranslation.translatedDescription
            languageBundle = localizationServices.bundleLoader.bundleForResource(resourceName: primaryLanguage.code) ?? Bundle.main
        }
        else if let englishTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageCode: "en") {
            
            nameValue = englishTranslation.translatedName
            aboutDetailsValue = englishTranslation.translatedDescription
            languageBundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
        }
        else {
            
            nameValue = resource.name
            aboutDetailsValue = resource.resourceDescription
            languageBundle = localizationServices.bundleLoader.englishBundle ?? Bundle.main
        }
                
        name = nameValue
        totalViews = String.localizedStringWithFormat(localizationServices.stringForBundle(bundle: languageBundle, key: "total_views"), resource.totalViews)
        openToolButtonTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "toolinfo_opentool")
        learnToShareToolButtonTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "toolDetails.learnToShareToolButton.title")
        addToFavoritesButtonTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "add_to_favorites")
        removeFromFavoritesButtonTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "remove_from_favorites")
        aboutDetails = aboutDetailsValue
        
        segments = segmentTypes.map({
            switch $0 {
            case .about:
                return localizationServices.stringForBundle(bundle: languageBundle, key: "about")
            case .versions:
                return localizationServices.stringForBundle(bundle: languageBundle, key: "toolDetails.versions.title")
            }
        })
        
        reloadMedia(resource: resource)
        reloadFavorited(resourceId: resource.id)
        reloadLearnToShareToolButtonState(resourceId: resource.id)
        
        toolVersions = getToolVersionsUseCase.getToolVersions(resourceId: resource.id)
        
        if selectedToolVersion == nil {
            selectedToolVersion = toolVersions.filter({$0.isDefaultVersion}).first
        }
    }
    
    private func reloadMedia(resource: ResourceModel) {
        
        let media: ToolDetailsMediaType
        
        if !resource.attrAboutOverviewVideoYoutube.isEmpty {
            
            let playsInFullScreen: Int = 0
            let playerParameters: [String: Any] = [Strings.YoutubePlayerParameters.playsInline.rawValue: playsInFullScreen]
            
            media = .youtube(videoId: resource.attrAboutOverviewVideoYoutube, playerParameters: playerParameters)
        }
        else if !resource.attrAboutBannerAnimation.isEmpty, let filePath = dataDownloader.attachmentsFileCache.getAttachmentFileUrl(attachmentId: resource.attrAboutBannerAnimation)?.path {
            
            let resource: AnimatedResource = .filepathJsonFile(filepath: filePath)
            let viewModel = AnimatedViewModel(animationDataResource: resource, autoPlay: true, loop: true)
            
            media = .animation(viewModel: viewModel)
        }
        else if let uiImage = dataDownloader.attachmentsFileCache.getAttachmentBanner(attachmentId: resource.attrBannerAbout) {
            let image: Image = Image(uiImage: uiImage)
            media = .image(image: image)
        }
        else {
            media = .empty
        }
        
        mediaType = media
    }
    
    private func reloadFavorited(resourceId: String) {
                
        isFavorited = favoritedResourcesCache.isFavorited(resourceId: resourceId)
    }
    
    private func reloadLearnToShareToolButtonState(resourceId: String) {
        
        guard let primaryLanguage = languageSettingsService.primaryLanguage.value else {
            return
        }
        
        let determineToolTranslationsToDownload = DetermineToolTranslationsToDownload(
            resourceId: resourceId,
            languageIds: [primaryLanguage.id],
            resourcesCache: dataDownloader.resourcesCache,
            languagesRepository: languagesRepository
        )
        
        getToolTranslationsUseCase.getToolTranslations(determineToolTranslationsToDownload: determineToolTranslationsToDownload, downloadStarted: {
            // download started, currently nothing will be shown while this downloads in the background. ~Levi
        }, downloadFinished: { [weak self] (result: Result<ToolTranslations, GetToolTranslationsError>) in
            DispatchQueue.main.async { [weak self] in
                
                let hidesLearnToShareToolButtonValue: Bool
                
                switch result {
                case .success(let toolTranslations):
                    
                    if let primaryLanguageTranslationManifest = toolTranslations.languageTranslationManifests.first {
                        
                        hidesLearnToShareToolButtonValue = primaryLanguageTranslationManifest.manifest.tips.isEmpty
                    }
                    else {
                        
                        hidesLearnToShareToolButtonValue = true
                    }
                    
                case .failure( _):
                    
                    hidesLearnToShareToolButtonValue = true
                }
                
                self?.hidesLearnToShareToolButton = hidesLearnToShareToolButtonValue
            }
        })
    }
    
    func backButtonTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromToolDetails)
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: siteSection, siteSubSection: siteSubSection))
    }
    
    func openToolTapped() {
        
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: analyticsScreenName, actionName: AnalyticsConstants.ActionNames.aboutToolOpened, siteSection: siteSection, siteSubSection: siteSubSection, url: nil, data: [AnalyticsConstants.Keys.toolAboutOpened: 1]))
        
        flowDelegate?.navigate(step: .openToolTappedFromToolDetails(resource: resource))
    }
    
    func learnToShareToolTapped() {
        
        flowDelegate?.navigate(step: .learnToShareToolTappedFromToolDetails(resource: resource))
    }
    
    func toggleFavorited() {
        
        if isFavorited {
            
            favoritedResourcesCache.removeFromFavorites(resourceId: resource.id)
        }
        else {
            
            favoritedResourcesCache.addToFavorites(resourceId: resource.id)
        }
    }
    
    func segmentTapped(index: Int) {
        selectedSegment = segmentTypes[index]
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
    
    func toolVersionTapped(toolVersion: ToolVersionDomainModel) {
        selectedToolVersion = toolVersion
    }
    
    func getToolVersionCardViewModel(toolVersion: ToolVersionDomainModel) -> ToolDetailsVersionsCardViewModel {
        
        return ToolDetailsVersionsCardViewModel(
            toolVersion: toolVersion,
            bannerImageRepository: bannerImageRepository,
            isSelected: selectedToolVersion?.id == toolVersion.id
        )
    }
}
