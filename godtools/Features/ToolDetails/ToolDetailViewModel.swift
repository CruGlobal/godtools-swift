//
//  ToolDetailViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolDetailViewModel: ToolDetailViewModelType {
    
    private let resource: ResourceModel
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
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, resourcesService: ResourcesService, languageSettingsCache: LanguageSettingsCacheType, localization: LocalizationServices, analytics: AnalyticsContainer, exitLinkAnalytics: ExitLinkAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.analytics = analytics
        self.exitLinkAnalytics = exitLinkAnalytics
        
        name.accept(value: resource.name)
        
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
        
        //
        languageSettingsCache.getPrimaryLanguage { [weak self] (language: LanguageModel?) in
            
            let languageBundle: Bundle = localization.bundleForLanguageElseMainBundle(languageCode: language?.code ?? "")
            
            self?.totalViews.accept(value: String.localizedStringWithFormat(localization.stringForBundle(bundle: languageBundle, key: "total_views"), self?.resource.totalViews ?? 0))
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
                title: String.localizedStringWithFormat(localization.stringForBundle(bundle: languageBundle, key: "total_languages"), self?.resource.languageIds.count ?? 0),
                controlId: .languages
            )
            self?.toolDetailsControls.accept(value: [aboutDetailsControl, languageDetailsControl])
            self?.selectedDetailControl.accept(value: aboutDetailsControl)
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
    
    var aboutDetails: String {
        
        /*
        let resourceDescription: String = resource.descr ?? ""
        
        let languagesManager = LanguagesManager()
        
        var languageOrder: [Language] = Array()
        
        if let primaryLanguage = languagesManager.loadPrimaryLanguageFromDisk() {
            languageOrder.append(primaryLanguage)
        }
        
        if let deviceLanguage = languagesManager.loadDevicePreferredLanguageFromDisk() {
            languageOrder.append(deviceLanguage)
        }
        
        if let englishLanguage = languagesManager.loadFromDisk(id: "en") {
            languageOrder.append(englishLanguage)
        }
        
        for language in languageOrder {
            if let translation = resource.getTranslationForLanguage(language) {
                if let description = translation.localizedDescription, !description.isEmpty {
                    return description
                }
            }
        }
        
        return resourceDescription*/
        return ""
    }
    
    var languageDetails: String {
        /*
        let primaryLanguage = LanguagesManager().loadPrimaryLanguageFromDisk()
        let languageCode = primaryLanguage?.code ?? "en"
        let locale = resource.isAvailableInLanguage(primaryLanguage) ? Locale(identifier:  languageCode) : Locale.current
        let resourceTranslations: [Translation] = Array(resource.translations)
        var translationStrings: [String] = []
        
        for translation in resourceTranslations {
            guard translation.language != nil else {
                continue
            }
            guard let languageLocalName = translation.language?.localizedName(locale: locale) else {
                continue
            }
            translationStrings.append(languageLocalName)
        }
        
        return translationStrings.sorted(by: { $0 < $1 }).joined(separator: ", ")
        */
        return ""
    }
}
