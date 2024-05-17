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
    
    typealias ToolId = String
    
    private static var toggleToolFavoritedCancellables: Dictionary<ToolId, AnyCancellable?> = Dictionary()
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewToolDetailsUseCase: ViewToolDetailsUseCase
    private let getToolDetailsMediaUseCase: GetToolDetailsMediaUseCase
    private let getToolDetailsLearnToShareToolIsAvailableUseCase: GetToolDetailsLearnToShareToolIsAvailableUseCase
    private let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase
    private let attachmentsRepository: AttachmentsRepository
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let primaryLanguage: AppLanguageDomainModel
    private let parallelLanguage: AppLanguageDomainModel?
    private let selectedLanguageIndex: Int?
    
    private var segmentTypes: [ToolDetailsSegmentType] = Array()
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var toolId: String {
        willSet {
            showsLearnToShareToolButton = false
        }
    }
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var analyticsToolAbbreviation: String = ""
    @Published private var didViewPage: Void?
    
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
    
    init(flowDelegate: FlowDelegate, toolId: String, primaryLanguage: AppLanguageDomainModel, parallelLanguage: AppLanguageDomainModel?, selectedLanguageIndex: Int?, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewToolDetailsUseCase: ViewToolDetailsUseCase, getToolDetailsMediaUseCase: GetToolDetailsMediaUseCase, getToolDetailsLearnToShareToolIsAvailableUseCase: GetToolDetailsLearnToShareToolIsAvailableUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase, attachmentsRepository: AttachmentsRepository, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        let primaryLanguage: AppLanguageDomainModel = primaryLanguage
        let parallelLanguage: AppLanguageDomainModel? = parallelLanguage != primaryLanguage ? parallelLanguage : nil
        
        self.flowDelegate = flowDelegate
        self.toolId = toolId
        self.primaryLanguage = primaryLanguage
        self.parallelLanguage = parallelLanguage
        self.selectedLanguageIndex = selectedLanguageIndex
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
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
            .assign(to: &$appLanguage)
        
        Publishers.CombineLatest(
            $didViewPage,
            $analyticsToolAbbreviation.dropFirst()
        )
        .flatMap({ [weak self] (pageViewed: Void?, analyticsToolAbbreviation: String) -> AnyPublisher<Void, Never> in
            
            guard !analyticsToolAbbreviation.isEmpty, pageViewed != nil, let weakSelf = self else {
                return Just(())
                    .eraseToAnyPublisher()
            }
            
            weakSelf.didViewPage = nil
            
            trackScreenViewAnalyticsUseCase.trackScreen(
                screenName: weakSelf.getAnalyticsScreenName(analyticsToolAbbreviation: analyticsToolAbbreviation),
                siteSection: weakSelf.getAnalyticsScreenName(analyticsToolAbbreviation: analyticsToolAbbreviation),
                siteSubSection: weakSelf.analyticsSiteSubSection,
                contentLanguage: nil,
                contentLanguageSecondary: nil
            )
            
            return Just(())
                .eraseToAnyPublisher()
        })
        .receive(on: DispatchQueue.main)
        .sink { (void: Void) in
            
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $toolId,
            $appLanguage.dropFirst()
        )
        .map { (toolId: String, appLanguage: AppLanguageDomainModel) in
            
            return viewToolDetailsUseCase
                .viewPublisher(toolId: toolId, translateInLanguage: appLanguage, toolPrimaryLanguage: primaryLanguage, toolParallelLanguage: parallelLanguage)
                .eraseToAnyPublisher()
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { [weak self] (domainModel: ViewToolDetailsDomainModel) in
            
            self?.analyticsToolAbbreviation = domainModel.toolDetails.analyticsToolAbbreviation
            
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
                self?.selectedToolVersion = domainModel.toolDetails.versions.filter({$0.id == self?.toolId}).first
            }
        })
        .store(in: &cancellables)
        
        $toolId.eraseToAnyPublisher()
            .flatMap({ (toolId: String) -> AnyPublisher<ToolDetailsMediaDomainModel, Never> in
                
                return getToolDetailsMediaUseCase
                    .getMediaPublisher(toolId: toolId)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .assign(to: &$mediaType)
        
        $toolId.eraseToAnyPublisher()
            .flatMap({ (toolId: String) -> AnyPublisher<Bool, Never> in
                
                return getToolDetailsLearnToShareToolIsAvailableUseCase
                    .getIsAvailablePublisher(toolId: toolId, language: primaryLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .assign(to: &$showsLearnToShareToolButton)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func getAnalyticsScreenName(analyticsToolAbbreviation: String) -> String {
        return analyticsToolAbbreviation + "-tool-info"
    }
    
    private func getAnalyticsSiteSection(analyticsToolAbbreviation: String) -> String {
        return analyticsToolAbbreviation
    }
    
    private var analyticsSiteSubSection: String {
        return "tool-info"
    }
    
    private func trackToolVersionTappedAnalytics(toolVersion: ToolVersionDomainModel) {
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: getAnalyticsScreenName(analyticsToolAbbreviation: toolVersion.analyticsToolAbbreviation),
            actionName: AnalyticsConstants.ActionNames.openDetails,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.versions,
                AnalyticsConstants.Keys.tool: toolVersion.analyticsToolAbbreviation
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
        
        didViewPage = ()
    }
    
    func openToolTapped() {
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: getAnalyticsScreenName(analyticsToolAbbreviation: analyticsToolAbbreviation),
            actionName: AnalyticsConstants.ActionNames.toolOpened,
            siteSection: getAnalyticsSiteSection(analyticsToolAbbreviation: analyticsToolAbbreviation),
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.toolDetails,
                AnalyticsConstants.Keys.tool: analyticsToolAbbreviation
            ]
        )
        
        flowDelegate?.navigate(step: .openToolTappedFromToolDetails(toolId: toolId, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, selectedLanguageIndex: selectedLanguageIndex))
    }
    
    func learnToShareToolTapped() {
        
        flowDelegate?.navigate(step: .learnToShareToolTappedFromToolDetails(toolId: toolId, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, selectedLanguageIndex: selectedLanguageIndex))
    }
    
    func toggleFavorited() {
        
        let toolId: String = self.toolId
        
        ToolDetailsViewModel.toggleToolFavoritedCancellables[toolId] = toggleToolFavoritedUseCase
            .toggleFavoritedPublisher(toolId: toolId)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (domainModel: ToolIsFavoritedDomainModel) in
                self?.isFavorited = domainModel.isFavorited
            })
    }
    
    func segmentTapped(index: Int) {
        
        selectedSegment = segmentTypes[index]
    }
    
    func urlTapped(url: URL) {
           
        flowDelegate?.navigate(step: .urlLinkTappedFromToolDetail(url: url, screenName: getAnalyticsScreenName(analyticsToolAbbreviation: analyticsToolAbbreviation), siteSection: getAnalyticsSiteSection(analyticsToolAbbreviation: analyticsToolAbbreviation), siteSubSection: analyticsSiteSubSection, contentLanguage: nil, contentLanguageSecondary: nil))
    }
    
    func toolVersionTapped(toolVersion: ToolVersionDomainModel) {
        
        toolId = toolVersion.dataModelId
            
        selectedToolVersion = toolVersion

        trackToolVersionTappedAnalytics(toolVersion: toolVersion)
    }
    
    func toolVersionCardWillAppear(toolVersion: ToolVersionDomainModel) -> ToolDetailsVersionsCardViewModel {
        
        return ToolDetailsVersionsCardViewModel(
            toolVersion: toolVersion,
            attachmentsRepository: attachmentsRepository,
            isSelected: selectedToolVersion?.id == toolVersion.id
        )
    }
}
