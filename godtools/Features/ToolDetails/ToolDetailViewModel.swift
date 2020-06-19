//
//  ToolDetailViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import RealmSwift

class ToolDetailViewModel: ToolDetailViewModelType {
    
    private let resource: ResourceModel
    private let resourcesService: ResourcesService
    private let languageSettingsCache: LanguageSettingsCacheType
    private let localization: LocalizationServices
    private let preferredLanguageTranslation: PreferredLanguageTranslationViewModel
    private let analytics: AnalyticsContainer
    private let exitLinkAnalytics: ExitLinkAnalytics
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let topToolDetailMedia: ObservableValue<ToolDetailMedia?> = ObservableValue(value: nil)
    let hidesBannerImage: Bool
    let hidesYoutubePlayer: Bool
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
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, resourcesService: ResourcesService, languageSettingsCache: LanguageSettingsCacheType, localization: LocalizationServices, preferredLanguageTranslation: PreferredLanguageTranslationViewModel, analytics: AnalyticsContainer, exitLinkAnalytics: ExitLinkAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.resourcesService = resourcesService
        self.languageSettingsCache = languageSettingsCache
        self.localization = localization
        self.preferredLanguageTranslation = preferredLanguageTranslation
        self.analytics = analytics
        self.exitLinkAnalytics = exitLinkAnalytics
                
        if !resource.attrAboutOverviewVideoYoutube.isEmpty {
            hidesBannerImage = true
            hidesYoutubePlayer = false
            topToolDetailMedia.accept(value: ToolDetailMedia(bannerImage: nil, youtubePlayerId: resource.attrAboutOverviewVideoYoutube))
        }
        else {
            hidesBannerImage = false
            hidesYoutubePlayer = true
            resourcesService.attachmentsService.getAttachmentBanner(attachmentId: resource.attrBannerAbout) { [weak self] (image: UIImage?) in
                self?.topToolDetailMedia.accept(value: ToolDetailMedia(bannerImage: image, youtubePlayerId: ""))
            }
        }
        
        reloadData(
            resource: resource,
            resourcesCache: resourcesService.realmResourcesCache,
            userSettingsPrimaryLanguageId: languageSettingsCache.primaryLanguageId.value ?? "",
            localization: localization
        )
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func reloadData(resource: ResourceModel, resourcesCache: RealmResourcesCache, userSettingsPrimaryLanguageId: String, localization: LocalizationServices) {
        
        preferredLanguageTranslation.getPreferredLanguageTranslation(resourceId: resource.id) { [weak self] (translation: TranslationModel?) in
                        
            if let preferredTranslation = translation {
                self?.name.accept(value: preferredTranslation.translatedName)
                self?.aboutDetails.accept(value: preferredTranslation.translatedDescription)
            }
            else {
                self?.name.accept(value: resource.name)
                self?.aboutDetails.accept(value: resource.resourceDescription)
            }
        }
        
        resourcesCache.realmDatabase.background { (realm: Realm) in
            
            let resourceTotalViews: Int
            let numberOfLanguages: Int
            let languageDetails: String
            let languageBundle: Bundle
            
            if let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: resource.id) {
                
                let languages: [RealmLanguage] = Array(realmResource.languages)
                let languageNames: [String] = languages.map({LanguageNameViewModel(language: $0).name})
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
        
    }
    
    func unfavoriteTapped() {
        
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
