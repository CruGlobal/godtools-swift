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
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getToolUseCase: GetToolUseCase
    private let viewToolDetailsUseCase: ViewToolDetailsUseCase
    private let getToolDetailsMediaUseCase: GetToolDetailsMediaUseCase
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
    @Published private var primaryLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    @Published private var parallelLanguage: AppLanguageDomainModel?
    
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
    
    init(flowDelegate: FlowDelegate, tool: ToolDomainModel, primaryLanguage: AppLanguageDomainModel?, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getToolUseCase: GetToolUseCase, viewToolDetailsUseCase: ViewToolDetailsUseCase, getToolDetailsMediaUseCase: GetToolDetailsMediaUseCase, getToolDetailsLearnToShareToolIsAvailableUseCase: GetToolDetailsLearnToShareToolIsAvailableUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase, attachmentsRepository: AttachmentsRepository, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.tool = tool
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getToolUseCase = getToolUseCase
        self.viewToolDetailsUseCase = viewToolDetailsUseCase
        self.getToolDetailsMediaUseCase = getToolDetailsMediaUseCase
        self.getToolDetailsLearnToShareToolIsAvailableUseCase = getToolDetailsLearnToShareToolIsAvailableUseCase
        self.toggleToolFavoritedUseCase = toggleToolFavoritedUseCase
        self.attachmentsRepository = attachmentsRepository
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] appLanguage in
                
                if let primaryLanguage = primaryLanguage {
                    
                    self?.primaryLanguage = primaryLanguage
                    
                    if primaryLanguage != appLanguage {
                        self?.parallelLanguage = appLanguage
                    }
                }
                else {
                    
                    self?.primaryLanguage = appLanguage
                    self?.parallelLanguage = nil
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest($tool.eraseToAnyPublisher(), $primaryLanguage.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .flatMap ({ (tool: ToolDomainModel, toolLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolDetailsDomainModel, Never> in
                
                return self.viewToolDetailsUseCase
                    .viewPublisher(tool: tool, translateInToolLanguage: toolLanguage)
                    .eraseToAnyPublisher()
            })
            .sink(receiveValue: { [weak self] (domainModel: ViewToolDetailsDomainModel) in
                
                self?.openToolButtonTitle = domainModel.interfaceStrings.openToolButtonTitle
                self?.learnToShareToolButtonTitle = domainModel.interfaceStrings.learnToShareThisToolButtonTitle
                self?.addToFavoritesButtonTitle = domainModel.interfaceStrings.addToFavoritesButtonTitle
                self?.removeFromFavoritesButtonTitle = domainModel.interfaceStrings.removeFromFavoritesButtonTitle
                self?.conversationStartersTitle = domainModel.interfaceStrings.conversationStartersTitle
                self?.outlineTitle = domainModel.interfaceStrings.outlineTitle
                self?.bibleReferencesTitle = domainModel.interfaceStrings.bibleReferencesTitle
                self?.languagesAvailableTitle = domainModel.interfaceStrings.languagesAvailableTitle
                
                self?.toolVersions = domainModel.toolDetails.versions
                self?.name = domainModel.toolDetails.name
                self?.totalViews = domainModel.toolDetails.numberOfViews
                self?.isFavorited = domainModel.toolDetails.isFavorited
                self?.aboutDescription = domainModel.toolDetails.aboutDescription
                self?.conversationStartersContent = domainModel.toolDetails.conversationStarters
                self?.bibleReferencesContent = domainModel.toolDetails.bibleReferences
                self?.languagesAvailable = domainModel.toolDetails.languagesAvailable
                self?.versionsDescription = domainModel.toolDetails.versionsDescription
                
                var segmentTypes: [ToolDetailsSegmentType] = Array()
                segmentTypes.append(.about)
                if !domainModel.toolDetails.versions.isEmpty {
                    segmentTypes.append(.versions)
                }
                
                self?.segmentTypes = segmentTypes
                
                self?.segments = segmentTypes.map({
                    switch $0 {
                    case .about:
                        return domainModel.interfaceStrings.aboutButtonTitle
                    case .versions:
                        return domainModel.interfaceStrings.versionsButtonTitle
                    }
                })
                
                if self?.selectedToolVersion == nil {
                    self?.selectedToolVersion = domainModel.toolDetails.versions.filter({$0.id == tool.id}).first
                }
            })
            .store(in: &cancellables)
        
        getToolDetailsMediaUseCase
            .getMediaPublisher(toolChangedPublisher: $tool.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .assign(to: &$mediaType)
        
        getToolDetailsLearnToShareToolIsAvailableUseCase
            .getIsAvailablePublisher(
                toolChangedPublisher: $tool.eraseToAnyPublisher(),
                toolLanguageCodeChangedPublisher: $primaryLanguage.eraseToAnyPublisher()
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
        
        flowDelegate?.navigate(step: .openToolTappedFromToolDetails(tool: tool, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage))
    }
    
    func learnToShareToolTapped() {
        
        flowDelegate?.navigate(step: .learnToShareToolTappedFromToolDetails(tool: tool, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage))
    }
    
    func toggleFavorited() {
        
        ToolDetailsViewModel.toggleToolFavoriteCancellable = toggleToolFavoritedUseCase
            .toggleToolFavoritedPublisher(id: self.tool.dataModelId)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (isFavorited: Bool) in
                self?.isFavorited = isFavorited
            })
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
