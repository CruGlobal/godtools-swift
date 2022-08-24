//
//  ToolDetailsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class ToolDetailsViewModel: ObservableObject {
    
    private let resourcesRepository: ResourcesRepository
    private let getToolDetailsMediaUseCase: GetToolDetailsMediaUseCase
    private let addToolToFavoritesUseCase: AddToolToFavoritesUseCase
    private let removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getToolLanguagesUseCase: GetToolLanguagesUseCase
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    private let getToolTranslationsFilesUseCase: GetToolTranslationsFilesUseCase
    private let languagesRepository: LanguagesRepository
    private let getToolVersionsUseCase: GetToolVersionsUseCase
    private let getBannerImageUseCase: GetBannerImageUseCase
    
    private var segmentTypes: [ToolDetailsSegmentType] = Array()
    private var resource: ResourceModel
    private var mediaCancellable: AnyCancellable?
    private var toolIsFavoritedCancellable: AnyCancellable?
    private var hidesLearnToShareCancellable: AnyCancellable?
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var mediaType: ToolDetailsMediaDomainModel = .empty
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
    @Published var availableLanguagesTitle: String = ""
    @Published var availableLanguagesList: String = ""
    @Published var versionsMessage: String = ""
    @Published var toolVersions: [ToolVersionDomainModel] = Array()
    @Published var selectedToolVersion: ToolVersionDomainModel?
    
    init(flowDelegate: FlowDelegate, resource: ResourceModel, resourcesRepository: ResourcesRepository, getToolDetailsMediaUseCase: GetToolDetailsMediaUseCase, addToolToFavoritesUseCase: AddToolToFavoritesUseCase, removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolLanguagesUseCase: GetToolLanguagesUseCase, localizationServices: LocalizationServices, analytics: AnalyticsContainer, getToolTranslationsFilesUseCase: GetToolTranslationsFilesUseCase, languagesRepository: LanguagesRepository, getToolVersionsUseCase: GetToolVersionsUseCase, getBannerImageUseCase: GetBannerImageUseCase) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.resourcesRepository = resourcesRepository
        self.getToolDetailsMediaUseCase = getToolDetailsMediaUseCase
        self.addToolToFavoritesUseCase = addToolToFavoritesUseCase
        self.removeToolFromFavoritesUseCase = removeToolFromFavoritesUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getToolLanguagesUseCase = getToolLanguagesUseCase
        self.localizationServices = localizationServices
        self.analytics = analytics
        self.getToolTranslationsFilesUseCase = getToolTranslationsFilesUseCase
        self.languagesRepository = languagesRepository
        self.getToolVersionsUseCase = getToolVersionsUseCase
        self.getBannerImageUseCase = getBannerImageUseCase
        self.availableLanguagesTitle = localizationServices.stringForMainBundle(key: "toolSettings.languagesAvailable.title")
        self.versionsMessage = localizationServices.stringForMainBundle(key: "toolDetails.versions.message")
        
        reloadToolDetails(resource: resource)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
    
    private func reloadToolDetails(resource: ResourceModel) {
        
        self.resource = resource
        
        let nameValue: String
        let aboutDetailsValue: String
        let languageBundle: Bundle
        
        if let primaryLanguage = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage(), let primaryTranslation = resourcesRepository.getResourceLanguageLatestTranslation(resourceId: resource.id, languageId: primaryLanguage.id) {
            
            nameValue = primaryTranslation.translatedName
            aboutDetailsValue = primaryTranslation.translatedDescription
            languageBundle = localizationServices.bundleLoader.bundleForResource(resourceName: primaryLanguage.localeIdentifier) ?? Bundle.main
        }
        else if let englishTranslation = resourcesRepository.getResourceLanguageLatestTranslation(resourceId: resource.id, languageCode: "en") {
            
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
                        
        availableLanguagesList = getToolLanguagesUseCase.getToolLanguages(resource: resource).map({$0.translatedName}).sorted(by: { $0 < $1 }).joined(separator: ", ")
        
        segmentTypes = [.about, .versions].filter({
            if $0 == .versions && resource.metatoolId == nil {
                return false
            }
            return true
        })
        
        segments = segmentTypes.map({
            switch $0 {
            case .about:
                return localizationServices.stringForBundle(bundle: languageBundle, key: "about")
            case .versions:
                return localizationServices.stringForBundle(bundle: languageBundle, key: "toolDetails.versions.title")
            }
        })
        
        reloadLearnToShareToolButtonState(resourceId: resource.id)
        
        if let metatoolId = resource.metatoolId {
            toolVersions = getToolVersionsUseCase.getToolVersions(resourceId: metatoolId)
        }
        
        if selectedToolVersion == nil {
            selectedToolVersion = toolVersions.filter({$0.id == resource.id}).first
        }
        
        mediaCancellable = getToolDetailsMediaUseCase.getMedia(resource: resource)
            .receive(on: DispatchQueue.main)
            .assign(to: \.mediaType, on: self)
        
        toolIsFavoritedCancellable = getToolIsFavoritedUseCase.getToolIsFavoritedPublisher(tool: resource)
            .receiveOnMain()
            .assign(to: \.isFavorited, on: self)
    }
    
    private func reloadLearnToShareToolButtonState(resourceId: String) {
        
        guard let primaryLanguage = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage() else {
            return
        }
        
        let determineToolTranslationsToDownload = DetermineToolTranslationsToDownload(resourceId: resourceId, languageIds: [primaryLanguage.id], resourcesRepository: resourcesRepository)
        
        hidesLearnToShareCancellable = getToolTranslationsFilesUseCase.getToolTranslationsFiles(filter: .downloadManifestAndRelatedFiles, determineToolTranslationsToDownload: determineToolTranslationsToDownload, downloadStarted: {
            
        })
        .receiveOnMain()
        .sink(receiveCompletion: { completed in
                        
        }, receiveValue: { [weak self] (toolTranslations: ToolTranslationsDomainModel) in
            
            let hidesLearnToShareToolButtonValue: Bool
            
            if let manifest = toolTranslations.languageTranslationManifests.first?.manifest {
                hidesLearnToShareToolButtonValue = manifest.tips.isEmpty
            }
            else {
                hidesLearnToShareToolButtonValue = true
            }
            
            self?.hidesLearnToShareToolButton = hidesLearnToShareToolButtonValue
        })
    }
    
    private func trackToolVersionTappedAnalytics(for tool: ResourceModel) {
        
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.openDetails,
            siteSection: "",
            siteSubSection: "",
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.versions,
                AnalyticsConstants.Keys.tool: tool.abbreviation
            ]
        ))
    }
}

// MARK: - Inputs

extension ToolDetailsViewModel {
    
    func backButtonTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromToolDetails)
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: siteSection, siteSubSection: siteSubSection))
    }
    
    func openToolTapped() {
        
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.toolOpened,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.toolDetails,
                AnalyticsConstants.Keys.tool: resource.abbreviation
            ])
        )

        flowDelegate?.navigate(step: .openToolTappedFromToolDetails(resource: resource))
    }
    
    func learnToShareToolTapped() {
        
        flowDelegate?.navigate(step: .learnToShareToolTappedFromToolDetails(resource: resource))
    }
    
    func toggleFavorited() {
        
        if isFavorited {
            removeToolFromFavoritesUseCase.removeToolFromFavorites(resourceId: resource.id)
        }
        else {
            addToolToFavoritesUseCase.addToolToFavorites(resourceId: resource.id)
        }
    }
    
    func segmentTapped(index: Int) {
        selectedSegment = segmentTypes[index]
        
        // NOTE: This is a temporary fix that solves an issue when switching back to the about section, a user is unable to scroll through all of the text in the
        // about section. This is basically acting as a way to force the view to refresh again after 0.1 seconds.
        // This has something to do with using UIViewRepresentable that wraps a UITextView.  If we were using a SwiftUI Text element this issue wouldn't exist.
        // Once minimum iOS 15 is supported see if TextWithLinks can be dropped.  See GT-1670. ~Levi
        if selectedSegment == .about {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.selectedSegment = .about
            }
        }
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
        
        guard let resource = resourcesRepository.getResource(id: toolVersion.dataModelId) else {
            return
        }
        
        selectedToolVersion = toolVersion

        trackToolVersionTappedAnalytics(for: resource)
        reloadToolDetails(resource: resource)
    }
    
    func toolVersionCardWillAppear(toolVersion: ToolVersionDomainModel) -> ToolDetailsVersionsCardViewModel {
        
        return ToolDetailsVersionsCardViewModel(
            toolVersion: toolVersion,
            getBannerImageUseCase: getBannerImageUseCase,
            isSelected: selectedToolVersion?.id == toolVersion.id
        )
    }
}
