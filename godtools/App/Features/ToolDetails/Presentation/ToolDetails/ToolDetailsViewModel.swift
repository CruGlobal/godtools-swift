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
    
    private static var toggleToolFavoriteCancellable: AnyCancellable?
    
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    private let getToolDetailsMediaUseCase: GetToolDetailsMediaUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getToolLanguagesUseCase: GetToolLanguagesUseCase
    private let localizationServices: LocalizationServices
    private let getToolTranslationsFilesUseCase: GetToolTranslationsFilesUseCase
    private let getToolVersionsUseCase: GetToolVersionsUseCase
    private let attachmentsRepository: AttachmentsRepository
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    
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
    @Published var conversationStartersTitle: String = ""
    @Published var conversationStartersContent: String = ""
    @Published var outlineTitle: String = ""
    @Published var outlineContent: String = ""
    @Published var bibleReferencesTitle: String = ""
    @Published var bibleReferencesContent: String = ""
    @Published var availableLanguagesTitle: String = ""
    @Published var availableLanguagesList: String = ""
    @Published var versionsMessage: String = ""
    @Published var toolVersions: [ToolVersionDomainModel] = Array()
    @Published var selectedToolVersion: ToolVersionDomainModel?
    
    init(flowDelegate: FlowDelegate, resource: ResourceModel, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, getToolDetailsMediaUseCase: GetToolDetailsMediaUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getToolLanguagesUseCase: GetToolLanguagesUseCase, localizationServices: LocalizationServices, getToolTranslationsFilesUseCase: GetToolTranslationsFilesUseCase, getToolVersionsUseCase: GetToolVersionsUseCase, attachmentsRepository: AttachmentsRepository, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        self.getToolDetailsMediaUseCase = getToolDetailsMediaUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.toggleToolFavoritedUseCase = toggleToolFavoritedUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getToolLanguagesUseCase = getToolLanguagesUseCase
        self.localizationServices = localizationServices
        self.getToolTranslationsFilesUseCase = getToolTranslationsFilesUseCase
        self.getToolVersionsUseCase = getToolVersionsUseCase
        self.attachmentsRepository = attachmentsRepository
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        self.versionsMessage = localizationServices.stringForSystemElseEnglish(key: "toolDetails.versions.message")
        
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
        let languageBundleFileType: LocalizableStringsFileType = .strings
        let languageBundle: LocalizableStringsBundle?
        let englishBundle: LocalizableStringsBundle? = localizationServices.bundleLoader.getEnglishBundle(fileType: languageBundleFileType)
        
        if let primaryLanguage = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage(), let primaryTranslation = translationsRepository.getLatestTranslation(resourceId: resource.id, languageId: primaryLanguage.id) {
            
            nameValue = primaryTranslation.translatedName
            aboutDetailsValue = primaryTranslation.translatedDescription
            bibleReferencesContent = primaryTranslation.toolDetailsBibleReferences
            conversationStartersContent = primaryTranslation.toolDetailsConversationStarters
            outlineContent = primaryTranslation.toolDetailsOutline
            languageBundle = localizationServices.bundleLoader.bundleForResource(resourceName: primaryLanguage.localeIdentifier, fileType: languageBundleFileType) ?? englishBundle
        }
        else if let englishTranslation = translationsRepository.getLatestTranslation(resourceId: resource.id, languageCode: "en") {
            
            nameValue = englishTranslation.translatedName
            aboutDetailsValue = englishTranslation.translatedDescription
            bibleReferencesContent = englishTranslation.toolDetailsBibleReferences
            conversationStartersContent = englishTranslation.toolDetailsConversationStarters
            outlineContent = englishTranslation.toolDetailsOutline
            languageBundle = englishBundle
        }
        else {
            
            nameValue = resource.name
            aboutDetailsValue = resource.resourceDescription
            languageBundle = englishBundle
        }
                
        name = nameValue
        totalViews = String.localizedStringWithFormat(languageBundle?.stringForKey(key: "total_views") ?? "", resource.totalViews)
        openToolButtonTitle = languageBundle?.stringForKey(key: "toolinfo_opentool") ?? ""
        learnToShareToolButtonTitle = languageBundle?.stringForKey(key: "toolDetails.learnToShareToolButton.title") ?? ""
        addToFavoritesButtonTitle = languageBundle?.stringForKey(key: "add_to_favorites") ?? ""
        removeFromFavoritesButtonTitle = languageBundle?.stringForKey(key: "remove_from_favorites") ?? ""
        aboutDetails = aboutDetailsValue
        conversationStartersTitle = languageBundle?.stringForKey(key: "toolDetails.conversationStarters.title") ?? ""
        outlineTitle = languageBundle?.stringForKey(key: "toolDetails.outline.title") ?? ""
        bibleReferencesTitle = languageBundle?.stringForKey(key: "toolDetails.bibleReferences.title") ?? ""
        availableLanguagesTitle = languageBundle?.stringForKey(key: "toolSettings.languagesAvailable.title") ?? ""
                        
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
                return languageBundle?.stringForKey(key: "toolDetails.about.title") ?? ""
            case .versions:
                return languageBundle?.stringForKey(key: "toolDetails.versions.title") ?? ""
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
        
        toolIsFavoritedCancellable = getToolIsFavoritedUseCase.getToolIsFavoritedPublisher(id: resource.id)
            .receive(on: DispatchQueue.main)
            .assign(to: \.isFavorited, on: self)
    }
    
    private func reloadLearnToShareToolButtonState(resourceId: String) {
        
        guard let primaryLanguage = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage() else {
            return
        }
        
        let determineToolTranslationsToDownload = DetermineToolTranslationsToDownload(
            resourceId: resourceId,
            languageIds: [primaryLanguage.id],
            resourcesRepository: resourcesRepository,
            translationsRepository: translationsRepository
        )
        
        hidesLearnToShareCancellable = getToolTranslationsFilesUseCase.getToolTranslationsFilesPublisher(filter: .downloadManifestForTipsCount, determineToolTranslationsToDownload: determineToolTranslationsToDownload, downloadStarted: {
            
        })
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completed in
                        
        }, receiveValue: { [weak self] (toolTranslations: ToolTranslationsDomainModel) in
            
            let hidesLearnToShareToolButtonValue: Bool
            
            if let manifest = toolTranslations.languageTranslationManifests.first?.manifest {
                hidesLearnToShareToolButtonValue = !manifest.hasTips
            }
            else {
                hidesLearnToShareToolButtonValue = true
            }
            
            self?.hidesLearnToShareToolButton = hidesLearnToShareToolButtonValue
        })
    }
    
    private func trackToolVersionTappedAnalytics(for tool: ResourceModel) {
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.openDetails,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.versions,
                AnalyticsConstants.Keys.tool: tool.abbreviation
            ]
        )
    }
}

// MARK: - Inputs

extension ToolDetailsViewModel {
    
    func pageViewed() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
    
    func openToolTapped() {
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.toolOpened,
            siteSection: siteSection,
            siteSubSection: siteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.toolDetails,
                AnalyticsConstants.Keys.tool: resource.abbreviation
            ]
        )
        
        flowDelegate?.navigate(step: .openToolTappedFromToolDetails(resource: resource))
    }
    
    func learnToShareToolTapped() {
        
        flowDelegate?.navigate(step: .learnToShareToolTappedFromToolDetails(resource: resource))
    }
    
    func toggleFavorited() {
        
        ToolDetailsViewModel.toggleToolFavoriteCancellable = toggleToolFavoritedUseCase.toggleToolFavoritedPublisher(id: resource.id)
            .sink { _ in
                
            }
    }
    
    func segmentTapped(index: Int) {
        
        selectedSegment = segmentTypes[index]
    }
    
    func urlTapped(url: URL) {
           
        flowDelegate?.navigate(step: .urlLinkTappedFromToolDetail(url: url, screenName: analyticsScreenName, siteSection: siteSection, siteSubSection: siteSubSection, contentLanguage: nil, contentLanguageSecondary: nil))
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
            attachmentsRepository: attachmentsRepository,
            isSelected: selectedToolVersion?.id == toolVersion.id
        )
    }
}
