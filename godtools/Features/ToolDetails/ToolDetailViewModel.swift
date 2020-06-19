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
    private let resourcesService: ResourcesService
    private let favoritedResourcesCache: RealmFavoritedResourcesCache
    private let languageSettingsService: LanguageSettingsService
    private let localization: LocalizationServices
    private let preferredLanguageTranslation: PreferredLanguageTranslationViewModel
    private let analytics: AnalyticsContainer
    private let exitLinkAnalytics: ExitLinkAnalytics
    private let translationsServices: ResourceTranslationsServices
    
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
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, resourcesService: ResourcesService, favoritedResourcesCache: RealmFavoritedResourcesCache, languageSettingsService: LanguageSettingsService, localization: LocalizationServices, preferredLanguageTranslation: PreferredLanguageTranslationViewModel, analytics: AnalyticsContainer, exitLinkAnalytics: ExitLinkAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.resourcesService = resourcesService
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languageSettingsService = languageSettingsService
        self.localization = localization
        self.preferredLanguageTranslation = preferredLanguageTranslation
        self.analytics = analytics
        self.exitLinkAnalytics = exitLinkAnalytics
        self.translationsServices = resourcesService.translationsServices
                
        super.init()
        
        if !resource.attrAboutOverviewVideoYoutube.isEmpty {
            hidesBannerImage.accept(value: true)
            hidesYoutubePlayer.accept(value: false)
            topToolDetailMedia.accept(value: ToolDetailMedia(bannerImage: nil, youtubePlayerId: resource.attrAboutOverviewVideoYoutube))
        }
        else {
            hidesBannerImage.accept(value: false)
            hidesYoutubePlayer.accept(value: true)
            resourcesService.attachmentsService.getAttachmentBanner(attachmentId: resource.attrBannerAbout) { [weak self] (image: UIImage?) in
                self?.topToolDetailMedia.accept(value: ToolDetailMedia(bannerImage: image, youtubePlayerId: ""))
            }
        }
        
        reloadData()
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        translationsServices.progress(resource: resource).removeObserver(self)
        favoritedResourcesCache.resourceFavorited.removeObserver(self)
        favoritedResourcesCache.resourceUnfavorited.removeObserver(self)
    }
    
    private func setupBinding() {
        
        translationsServices.progress(resource: resource).addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async { [weak self] in
                self?.translationDownloadProgress.accept(value: progress)
            }
        }
        
        favoritedResourcesCache.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.reloadFavorited()
        }
        
        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.reloadFavorited()
        }
    }
    
    private func reloadData() {
        
        let resource: ResourceModel = self.resource
        let resourcesCache: RealmResourcesCache = self.resourcesService.realmResourcesCache
        let languageSettingsService: LanguageSettingsService = self.languageSettingsService
        let userSettingsPrimaryLanguageId: String = languageSettingsService.primaryLanguage.value?.id ?? ""
        let localization: LocalizationServices = self.localization
        
        reloadFavorited()
        
        preferredLanguageTranslation.getPreferredLanguageTranslation(resourceId: resource.id, completeOnMain: { [weak self] (translation: TranslationModel?) in
            
            if let preferredTranslation = translation {
                self?.name.accept(value: preferredTranslation.translatedName)
                self?.aboutDetails.accept(value: preferredTranslation.translatedDescription)
            }
            else {
                self?.name.accept(value: resource.name)
                self?.aboutDetails.accept(value: resource.resourceDescription)
            }
        })
        
        resourcesCache.realmDatabase.background { (realm: Realm) in
            
            let resourceTotalViews: Int
            let numberOfLanguages: Int
            let languageDetails: String
            let languageBundle: Bundle
            
            if let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: resource.id) {
                
                let languages: [RealmLanguage] = Array(realmResource.languages)
                let languageNames: [String] = languages.map({LanguageNameTranslationViewModel(language: $0, languageSettingsService: languageSettingsService, shouldFallbackToPrimaryLanguageLocale: true).name})
                let sortedLanguageNames: String = languageNames.sorted(by: { $0 < $1 }).joined(separator: ", ")
                languageDetails = sortedLanguageNames
                
                resourceTotalViews = realmResource.totalViews
                numberOfLanguages = languages.count
            }
            else {
                languageDetails = ""
                resourceTotalViews = 0
                numberOfLanguages = 0
            }
            
            if let primaryLanguage = realm.object(ofType: RealmLanguage.self, forPrimaryKey: userSettingsPrimaryLanguageId) {
                languageBundle = localization.bundleForLanguageElseMainBundle(languageCode: primaryLanguage.code)
            }
            else {
                languageBundle = Bundle.main
            }
            
            DispatchQueue.main.async { [weak self] in
                
                self?.totalViews.accept(value: String.localizedStringWithFormat(localization.stringForBundle(bundle: languageBundle, key: "total_views"), resourceTotalViews))
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
            }
        }
    }
    
    private func reloadFavorited() {
        
        favoritedResourcesCache.isFavorited(resourceId: resource.id) { [weak self] (isFavorited: Bool) in
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
        //flowDelegate?.navigate(step: .openToolTappedFromToolDetails(resource: resource))
    }
    
    func favoriteTapped() {
        favoritedResourcesCache.addResourceToFavorites(resourceId: resource.id)
        resourcesService.translationsServices.downloadAndCacheTranslations(resource: resource)
    }
    
    func unfavoriteTapped() {
        favoritedResourcesCache.removeResourceFromFavorites(resourceId: resource.id)
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
