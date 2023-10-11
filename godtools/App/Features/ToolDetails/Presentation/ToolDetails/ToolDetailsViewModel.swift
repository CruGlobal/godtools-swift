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
    
    private let getToolDetailsInterfaceStringsInToolLanguageUseCase: GetToolDetailsInterfaceStringsInToolLanguageUseCase
    private let getToolDetailsInToolLanguageUseCase: GetToolDetailsInToolLanguageUseCase
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    private let getToolDetailsMediaUseCase: GetToolDetailsMediaUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let localizationServices: LocalizationServices
    private let getToolTranslationsFilesUseCase: GetToolTranslationsFilesUseCase
    private let attachmentsRepository: AttachmentsRepository
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    
    private var segmentTypes: [ToolDetailsSegmentType] = Array()
    private var resource: ResourceModel
    private var hidesLearnToShareCancellable: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var tool: ToolDomainModel
    @Published private var toolLanguage: String = LanguageCodeDomainModel.english.value // TODO: Should use type other than string here for better visibility? ~Levi
    
    @Published var mediaType: ToolDetailsMediaDomainModel = .empty
    @Published var name: String = ""
    @Published var totalViews: String = ""
    @Published var openToolButtonTitle: String = ""
    @Published var learnToShareToolButtonTitle: String = ""
    @Published var addToFavoritesButtonTitle: String = ""
    @Published var removeFromFavoritesButtonTitle: String = ""
    @Published var showsLearnToShareToolButton: Bool = false
    @Published var isFavorited: Bool = false
    @Published var segments: [String] = Array()
    @Published var selectedSegment: ToolDetailsSegmentType = .about
    @Published var aboutDescription: String = ""
    @Published var conversationStartersTitle: String = ""
    @Published var conversationStartersContent: String = ""
    @Published var outlineTitle: String = ""
    @Published var outlineContent: String = ""
    @Published var bibleReferencesTitle: String = ""
    @Published var bibleReferencesContent: String = ""
    @Published var languagesAvailableTitle: String = ""
    @Published var languagesAvailable: String = ""
    @Published var versionsDescription: String = ""
    @Published var toolVersions: [ToolVersionDomainModel] = Array()
    @Published var selectedToolVersion: ToolVersionDomainModel?
    
    init(flowDelegate: FlowDelegate, tool: ToolDomainModel, getToolDetailsInterfaceStringsInToolLanguageUseCase: GetToolDetailsInterfaceStringsInToolLanguageUseCase, getToolDetailsInToolLanguageUseCase: GetToolDetailsInToolLanguageUseCase, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, getToolDetailsMediaUseCase: GetToolDetailsMediaUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, localizationServices: LocalizationServices, getToolTranslationsFilesUseCase: GetToolTranslationsFilesUseCase, attachmentsRepository: AttachmentsRepository, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.tool = tool
        self.getToolDetailsInterfaceStringsInToolLanguageUseCase = getToolDetailsInterfaceStringsInToolLanguageUseCase
        self.getToolDetailsInToolLanguageUseCase = getToolDetailsInToolLanguageUseCase
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        self.getToolDetailsMediaUseCase = getToolDetailsMediaUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.toggleToolFavoritedUseCase = toggleToolFavoritedUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.localizationServices = localizationServices
        self.getToolTranslationsFilesUseCase = getToolTranslationsFilesUseCase
        self.attachmentsRepository = attachmentsRepository
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        if let resource = resourcesRepository.getResource(id: tool.dataModelId) {
            self.resource = resource
            reloadToolDetails(resource: resource) // TODO: Should remove this and reload when ToolDomainModel changes. ~Levi
        }
        else {
            assertionFailure("Failed to load resource from resources repository with id: \(tool.dataModelId)")
            self.resource = resourcesRepository.getResource(id: "1")!
        }
        
        getToolDetailsMediaUseCase.getMediaPublisher(resource: resource)
            .receive(on: DispatchQueue.main)
            .assign(to: &$mediaType)
        
        Publishers.CombineLatest(
            getToolDetailsInterfaceStringsInToolLanguageUseCase.getStringsPublisher(toolLanguageCodePublisher: $toolLanguage.eraseToAnyPublisher()),
            getToolDetailsInToolLanguageUseCase.getToolsDetailsPublisher(toolPublisher: $tool.eraseToAnyPublisher(), toolLanguageCodePublisher: $toolLanguage.eraseToAnyPublisher())
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (interfaceStrings: ToolDetailsInterfaceStringsDomainModel, toolDetails: ToolDetailsDomainModel) in
                        
            self?.openToolButtonTitle = interfaceStrings.openToolButtonTitle
            self?.learnToShareToolButtonTitle = interfaceStrings.learnToShareThisToolButtonTitle
            self?.addToFavoritesButtonTitle = interfaceStrings.addToFavoritesButtonTitle
            self?.removeFromFavoritesButtonTitle = interfaceStrings.removeFromFavoritesButtonTitle
            self?.conversationStartersTitle = interfaceStrings.conversationStartersTitle
            self?.outlineTitle = interfaceStrings.outlineTitle
            self?.bibleReferencesTitle = interfaceStrings.bibleReferencesTitle
            self?.languagesAvailableTitle = interfaceStrings.languagesAvailableTitle
            self?.toolVersions = toolDetails.versions
            
            self?.name = toolDetails.name
            self?.totalViews = toolDetails.numberOfViews
            self?.aboutDescription = toolDetails.aboutDescription
            self?.conversationStartersContent = toolDetails.conversationStarters
            self?.bibleReferencesContent = toolDetails.bibleReferences
            self?.languagesAvailable = toolDetails.languages.map({$0.languageNameTranslatedInToolLanguage}).sorted(by: { $0 < $1 }).joined(separator: ", ")
            self?.versionsDescription = toolDetails.versionsDescription
            
            var segmentTypes: [ToolDetailsSegmentType] = Array()
            segmentTypes.append(.about)
            if !toolDetails.versions.isEmpty {
                segmentTypes.append(.versions)
            }
            
            self?.segmentTypes = segmentTypes
            
            self?.segments = segmentTypes.map({
                switch $0 {
                case .about:
                    return interfaceStrings.aboutButtonTitle
                case .versions:
                    return interfaceStrings.versionsButtonTitle
                }
            })
            
            if self?.selectedToolVersion == nil {
                self?.selectedToolVersion = toolDetails.versions.filter({$0.id == tool.id}).first
            }
        }
        .store(in: &cancellables)
        
        $tool
            .flatMap({ (tool: ToolDomainModel) -> AnyPublisher<Bool, Never> in
                return self.getToolIsFavoritedUseCase.getToolIsFavoritedPublisher(id: tool.dataModelId)
                    .eraseToAnyPublisher()
            })
            .sink { [weak self] (isFavorited: Bool) in
                self?.isFavorited = isFavorited
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private var analyticsScreenName: String {
        return resource.abbreviation + "-tool-info"
    }
    
    private var analyticsSiteSection: String {
        return resource.abbreviation
    }
    
    private var analyticsSiteSubSection: String {
        return "tool-info"
    }
    
    private func reloadToolDetails(resource: ResourceModel) {
        
        self.resource = resource
        
        reloadLearnToShareToolButtonState(resourceId: resource.id)
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
            
            self?.showsLearnToShareToolButton = !hidesLearnToShareToolButtonValue
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
    
    @objc func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromToolDetails)
    }
    
    func pageViewed() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
    
    func openToolTapped() {
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.toolOpened,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
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
           
        flowDelegate?.navigate(step: .urlLinkTappedFromToolDetail(url: url, screenName: analyticsScreenName, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection, contentLanguage: nil, contentLanguageSecondary: nil))
    }
    
    func toolVersionTapped(toolVersion: ToolVersionDomainModel) {
        
        guard let resource = resourcesRepository.getResource(id: toolVersion.dataModelId) else {
            return
        }
        
        selectedToolVersion = toolVersion

        trackToolVersionTappedAnalytics(for: resource)
        
        reloadToolDetails(resource: resource) // TODO: Should remove this and reload when ToolDomainModel changes. ~Levi
    }
    
    func toolVersionCardWillAppear(toolVersion: ToolVersionDomainModel) -> ToolDetailsVersionsCardViewModel {
        
        return ToolDetailsVersionsCardViewModel(
            toolVersion: toolVersion,
            attachmentsRepository: attachmentsRepository,
            isSelected: selectedToolVersion?.id == toolVersion.id
        )
    }
}
