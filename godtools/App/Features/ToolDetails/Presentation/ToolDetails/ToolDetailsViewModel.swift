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
    
    private let getToolUseCase: GetToolUseCase
    private let getToolDetailsInterfaceStringsUseCase: GetToolDetailsInterfaceStringsUseCase
    private let getToolDetailsMediaUseCase: GetToolDetailsMediaUseCase
    private let getToolDetailsUseCase: GetToolDetailsUseCase
    private let getToolDetailsToolIsFavoritedUseCase: GetToolDetailsToolIsFavoritedUseCase
    private let getToolDetailsLearnToShareToolIsAvailableUseCase: GetToolDetailsLearnToShareToolIsAvailableUseCase
    private let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase
    private let attachmentsRepository: AttachmentsRepository
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    
    private var segmentTypes: [ToolDetailsSegmentType] = Array()
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var tool: ToolDomainModel {
        willSet {
            showsLearnToShareToolButton = false
        }
    }
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
    
    init(flowDelegate: FlowDelegate, tool: ToolDomainModel, getToolUseCase: GetToolUseCase, getToolDetailsInterfaceStringsUseCase: GetToolDetailsInterfaceStringsUseCase, getToolDetailsMediaUseCase: GetToolDetailsMediaUseCase, getToolDetailsUseCase: GetToolDetailsUseCase, getToolDetailsToolIsFavoritedUseCase: GetToolDetailsToolIsFavoritedUseCase, getToolDetailsLearnToShareToolIsAvailableUseCase: GetToolDetailsLearnToShareToolIsAvailableUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase, attachmentsRepository: AttachmentsRepository, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.tool = tool
        self.getToolUseCase = getToolUseCase
        self.getToolDetailsInterfaceStringsUseCase = getToolDetailsInterfaceStringsUseCase
        self.getToolDetailsMediaUseCase = getToolDetailsMediaUseCase
        self.getToolDetailsUseCase = getToolDetailsUseCase
        self.getToolDetailsToolIsFavoritedUseCase = getToolDetailsToolIsFavoritedUseCase
        self.getToolDetailsLearnToShareToolIsAvailableUseCase = getToolDetailsLearnToShareToolIsAvailableUseCase
        self.toggleToolFavoritedUseCase = toggleToolFavoritedUseCase
        self.attachmentsRepository = attachmentsRepository
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        getToolDetailsMediaUseCase
            .observeMediaPublisher(toolChangedPublisher: $tool.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .assign(to: &$mediaType)
        
        Publishers.CombineLatest(
            getToolDetailsInterfaceStringsUseCase.observeStringsPublisher(
                toolLanguageCodeChangedPublisher: $toolLanguage.eraseToAnyPublisher()
            ),
            getToolDetailsUseCase.observeToolDetailsPublisher(
                toolChangedPublisher: $tool.eraseToAnyPublisher(),
                toolLanguageCodeChangedPublisher: $toolLanguage.eraseToAnyPublisher()
            )
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
        
        getToolDetailsToolIsFavoritedUseCase
            .observeToolIsFavoritedPublisher(toolChangedPublisher: $tool.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .assign(to: &$isFavorited)
        
        getToolDetailsLearnToShareToolIsAvailableUseCase
            .observeIsAvailablePublisher(
                toolChangedPublisher: $tool.eraseToAnyPublisher(),
                toolLanguageCodeChangedPublisher: $toolLanguage.eraseToAnyPublisher()
            )
            .receive(on: DispatchQueue.main)
            .assign(to: &$showsLearnToShareToolButton)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private var analyticsScreenName: String {
        return tool.abbreviation + "-tool-info"
    }
    
    private var analyticsSiteSection: String {
        return tool.abbreviation
    }
    
    private var analyticsSiteSubSection: String {
        return "tool-info"
    }
    
    private func trackToolVersionTappedAnalytics(for tool: ToolDomainModel) {
        
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
                AnalyticsConstants.Keys.tool: tool.abbreviation
            ]
        )
        
        flowDelegate?.navigate(step: .openToolTappedFromToolDetails(tool: tool))
    }
    
    func learnToShareToolTapped() {
        
        flowDelegate?.navigate(step: .learnToShareToolTappedFromToolDetails(tool: tool))
    }
    
    func toggleFavorited() {
        
        ToolDetailsViewModel.toggleToolFavoriteCancellable = toggleToolFavoritedUseCase.toggleToolFavoritedPublisher(id: tool.dataModelId)
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
        
        guard let tool = getToolUseCase.getTool(id: toolVersion.dataModelId) else {
            return
        }
        
        self.tool = tool
            
        selectedToolVersion = toolVersion

        trackToolVersionTappedAnalytics(for: tool)
    }
    
    func toolVersionCardWillAppear(toolVersion: ToolVersionDomainModel) -> ToolDetailsVersionsCardViewModel {
        
        return ToolDetailsVersionsCardViewModel(
            toolVersion: toolVersion,
            attachmentsRepository: attachmentsRepository,
            isSelected: selectedToolVersion?.id == toolVersion.id
        )
    }
}
