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
    
    private let resource: ResourceModel
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let analytics: AnalyticsContainer
    private let getToolTranslationsUseCase: GetToolTranslationsUseCase
    private let languagesRepository: LanguagesRepository
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var mediaType: ToolDetailsMediaType
    @Published var name: String = ""
    @Published var totalViews: String = ""
    @Published var openToolButtonTitle: String = ""
    @Published var learnToShareToolButtonTitle: String = ""
    @Published var addToFavoritesButtonTitle: String = ""
    @Published var removeFromFavoritesButtonTitle: String = ""
    @Published var hidesLearnToShareToolButton: Bool = true
    @Published var hidesAddToFavoritesButton: Bool = false
    @Published var hidesRemoveFromFavoritesButton: Bool = true
    @Published var aboutDetails: String = ""
    
    init(flowDelegate: FlowDelegate, resource: ResourceModel, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritedResourcesCache: FavoritedResourcesCache, analytics: AnalyticsContainer, getToolTranslationsUseCase: GetToolTranslationsUseCase, languagesRepository: LanguagesRepository) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritedResourcesCache = favoritedResourcesCache
        self.analytics = analytics
        self.getToolTranslationsUseCase = getToolTranslationsUseCase
        self.languagesRepository = languagesRepository
        self.mediaType = ToolDetailsViewModel.getMediaType(resource: resource, dataDownloader: dataDownloader)
        
        super.init()
        
        reloadToolDetails()
        reloadFavorited()
        setupBinding()
        reloadLearnToShareToolButtonState()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        favoritedResourcesCache.resourceFavorited.removeObserver(self)
        favoritedResourcesCache.resourceUnfavorited.removeObserver(self)
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
                self?.reloadFavorited()
            }
        }
        
        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadFavorited()
            }
        }
    }
    
    private static func getMediaType(resource: ResourceModel, dataDownloader: InitialDataDownloader) -> ToolDetailsMediaType {
        
        let mediaType: ToolDetailsMediaType
        
        if !resource.attrAboutOverviewVideoYoutube.isEmpty {
            
            let playsInFullScreen: Int = 0
            let playerParameters: [String: Any] = ["playsinline": playsInFullScreen]
            
            mediaType = .youtube(videoId: resource.attrAboutOverviewVideoYoutube, playerParameters: playerParameters)
        }
        else if !resource.attrAboutBannerAnimation.isEmpty, let filePath = dataDownloader.attachmentsFileCache.getAttachmentFileUrl(attachmentId: resource.attrAboutBannerAnimation)?.path {
            
            let resource: AnimatedResource = .filepathJsonFile(filepath: filePath)
            let viewModel = AnimatedViewModel(animationDataResource: resource, autoPlay: true, loop: true)
            
            mediaType = .animation(viewModel: viewModel)
        }
        else if let uiImage = dataDownloader.attachmentsFileCache.getAttachmentBanner(attachmentId: resource.attrBannerAbout) {
            let image: Image = Image(uiImage: uiImage)
            mediaType = .image(image: image)
        }
        else {
            mediaType = .empty
        }
        
        return mediaType
    }
    
    private func reloadLearnToShareToolButtonState() {
        
        guard let primaryLanguage = languageSettingsService.primaryLanguage.value else {
            return
        }
        
        let determineToolTranslationsToDownload = DetermineToolTranslationsToDownload(
            resourceId: resource.id,
            languageIds: [primaryLanguage.id],
            resourcesCache: dataDownloader.resourcesCache,
            languagesRepository: languagesRepository
        )
        
        getToolTranslationsUseCase.getToolTranslations(determineToolTranslationsToDownload: determineToolTranslationsToDownload, downloadStarted: { [weak self] in
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
                    
                case .failure(let error):
                    
                    hidesLearnToShareToolButtonValue = true
                }
                
                self?.hidesLearnToShareToolButton = hidesLearnToShareToolButtonValue
            }
        })
    }
    
    private func reloadFavorited() {
                
        if favoritedResourcesCache.isFavorited(resourceId: resource.id) {
            hidesAddToFavoritesButton = true
            hidesRemoveFromFavoritesButton = false
        }
        else {
            hidesAddToFavoritesButton = false
            hidesRemoveFromFavoritesButton = true
        }
    }
    
    private func reloadToolDetails() {
        
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
        
        let languages: [LanguageModel] =  dataDownloader.resourcesCache.getResourceLanguages(resourceId: resource.id)
        let languageNames: [String] = languages.map({LanguageViewModel(language: $0, localizationServices: localizationServices).translatedLanguageName})
        let sortedLanguageNames: [String] = languageNames.sorted(by: { $0 < $1 })
        let languageDetailsValue: String = sortedLanguageNames.joined(separator: ", ")
        
        let numberOfLanguages: Int = languages.count
        
        name = nameValue
        totalViews = String.localizedStringWithFormat(localizationServices.stringForBundle(bundle: languageBundle, key: "total_views"), resource.totalViews)
        openToolButtonTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "toolinfo_opentool")
        learnToShareToolButtonTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "toolDetails.learnToShareToolButton.title")
        addToFavoritesButtonTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "add_to_favorites")
        removeFromFavoritesButtonTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "remove_from_favorites")
        aboutDetails = aboutDetailsValue
        
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
        
        //toolDetailsControls.accept(value: [aboutDetailsControl, languageDetailsControl])
        //selectedDetailControl.accept(value: aboutDetailsControl)
        
        //languageDetails.accept(value: languageDetailsValue)
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
    
    func addToFavoritesTapped() {
        
        favoritedResourcesCache.addToFavorites(resourceId: resource.id)
    }
    
    func removeFromFavoritesTapped() {
       
        favoritedResourcesCache.removeFromFavorites(resourceId: resource.id)
    }
}
