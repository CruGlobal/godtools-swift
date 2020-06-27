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
    private let favoritedResourcesService: FavoritedResourcesService
    private let languageSettingsService: LanguageSettingsService
    private let localization: LocalizationServices
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
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, dataDownloader: InitialDataDownloader, favoritedResourcesService: FavoritedResourcesService, languageSettingsService: LanguageSettingsService, localization: LocalizationServices, fetchLanguageTranslationViewModel: FetchLanguageTranslationViewModel, analytics: AnalyticsContainer, exitLinkAnalytics: ExitLinkAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.favoritedResourcesService = favoritedResourcesService
        self.languageSettingsService = languageSettingsService
        self.localization = localization
        self.fetchLanguageTranslationViewModel = fetchLanguageTranslationViewModel
        self.translateLanguageNameViewModel = TranslateLanguageNameViewModel(languageSettingsService: languageSettingsService, shouldFallbackToPrimaryLanguageLocale: true)
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
            dataDownloader.attachmentsFileCache.getAttachmentBanner(attachmentId: resource.attrBannerAbout) { [weak self] (image: UIImage?) in
                self?.topToolDetailMedia.accept(value: ToolDetailMedia(bannerImage: image, youtubePlayerId: ""))
            }
        }
        
        reloadFavorited()
        reloadToolDetails()
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        favoritedResourcesService.resourceFavorited.removeObserver(self)
        favoritedResourcesService.resourceUnfavorited.removeObserver(self)
    }
    
    private func setupBinding() {
        
        favoritedResourcesService.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.reloadFavorited()
        }
        
        favoritedResourcesService.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.reloadFavorited()
        }
    }
    
    private func reloadFavorited() {
                
        favoritedResourcesService.isFavorited(resourceId: resource.id) { [weak self] (isFavorited: Bool) in
            if isFavorited {
                self?.hidesFavoriteButton.accept(value: true)
                self?.hidesUnfavoriteButton.accept(value: false)
            }
            else {
                self?.hidesFavoriteButton.accept(value: false)
                self?.hidesUnfavoriteButton.accept(value: true)
            }
        }
    }
    
    private func reloadToolDetails() {
        
        let resource: ResourceModel = self.resource
        let resourcesCache: RealmResourcesCache = dataDownloader.resourcesCache
        let translateLanguageNameViewModel: TranslateLanguageNameViewModel = self.translateLanguageNameViewModel
        let localization: LocalizationServices = self.localization
        let primaryLanguageId: String = languageSettingsService.primaryLanguage.value?.id ?? ""
        
        fetchLanguageTranslationViewModel.getLanguageTranslation(resourceId: resource.id, languageId: primaryLanguageId, supportedFallbackTypes: FetchLanguageTranslationFallbackType.all, completeOnMain: { [weak self] (primaryTranslationResult: FetchLanguageTranslationResult) in
            
            let languageBundle: Bundle
            
            if let preferredLanguage = primaryTranslationResult.language {
                languageBundle = localization.bundleForLanguageElseMainBundle(languageCode: preferredLanguage.code)
            }
            else {
                languageBundle = Bundle.main
            }
            
            if let preferredTranslation = primaryTranslationResult.translation {
                self?.name.accept(value: preferredTranslation.translatedName)
                self?.aboutDetails.accept(value: preferredTranslation.translatedDescription)
            }
            else {
                self?.name.accept(value: resource.name)
                self?.aboutDetails.accept(value: resource.resourceDescription)
            }
            
            resourcesCache.getResourceLanguages(resourceId: resource.id, completeOnMain: { [weak self] (languages: [LanguageModel]) in
                
                let languageNames: [String] = languages.map({$0.translatedName(translateLanguageNameViewModel: translateLanguageNameViewModel)})
                let sortedLanguageNames: String = languageNames.sorted(by: { $0 < $1 }).joined(separator: ", ")
                
                let languageDetails: String = sortedLanguageNames
                let numberOfLanguages: Int = languages.count
                
                self?.totalViews.accept(value: String.localizedStringWithFormat(localization.stringForBundle(bundle: languageBundle, key: "total_views"), resource.totalViews))
                self?.openToolTitle.accept(value: localization.stringForBundle(bundle: languageBundle, key: "toolinfo_opentool"))
                self?.unfavoriteTitle.accept(value: localization.stringForBundle(bundle: languageBundle, key: "remove_from_favorites"))
                self?.favoriteTitle.accept(value: localization.stringForBundle(bundle: languageBundle, key: "add_to_favorites"))
                
                // tool details
                let aboutDetailsControl = ToolDetailControl(
                    id: "about",
                    title: localization.stringForBundle(bundle: languageBundle, key: "about"),
                    controlId: .about
                )
                
                let languageDetailsControl = ToolDetailControl(
                    id: "language",
                    title: String.localizedStringWithFormat(localization.stringForBundle(bundle: languageBundle, key: "total_languages"), numberOfLanguages),
                    controlId: .languages
                )
                self?.toolDetailsControls.accept(value: [aboutDetailsControl, languageDetailsControl])
                self?.selectedDetailControl.accept(value: aboutDetailsControl)
                
                self?.languageDetails.accept(value: languageDetails)
            })
        })
    }
    
    private var screenName: String {
        return resource.abbreviation + "-" + "tool-info"
    }
    
    private var siteSection: String {
        return resource.abbreviation
    }
    
    private var siteSubSection: String {
        return ""
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection)
    }
    
    func openToolTapped() {
        flowDelegate?.navigate(step: .openToolTappedFromToolDetails(resource: resource))
    }
    
    func favoriteTapped() {
        favoritedResourcesService.addToFavorites(resourceId: resource.id)
        //resourcesService.translationsServices.downloadAndCacheTranslations(resource: resource)
    }
    
    func unfavoriteTapped() {
        favoritedResourcesService.removeFromFavorites(resourceId: resource.id)
    }
    
    func detailControlTapped(detailControl: ToolDetailControl) {
        
        selectedDetailControl.accept(value: detailControl)
    }
    
    func urlTapped(url: URL) {
                
        exitLinkAnalytics.trackExitLink(
            screenName: screenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            url: url
        )
        
        flowDelegate?.navigate(step: .urlLinkTappedFromToolDetail(url: url))
    }
}
