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

@MainActor class ToolDetailsViewModel: ObservableObject {
    
    typealias ToolId = String
    
    private static var toggleToolFavoritedCancellables: [ToolId: AnyCancellable?] = Dictionary()
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getToolDetailsStringsUseCase: GetToolDetailsStringsUseCase
    private let getToolDetailsUseCase: GetToolDetailsUseCase
    private let getToolDetailsMediaUseCase: GetToolDetailsMediaUseCase
    private let getToolDetailsLearnToShareToolIsAvailableUseCase: GetToolDetailsLearnToShareToolIsAvailableUseCase
    private let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase
    private let getToolBannerUseCase: GetToolBannerUseCase
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
    @Published private var didViewPage: Void?
    @Published private var analyticsToolAbbreviation: String = ""
    
    @Published private(set) var strings = ToolDetailsStringsDomainModel.emptyValue
    @Published private(set) var mediaType: ToolDetailsMediaDomainModel = .empty
    @Published private(set) var toolDetails = ToolDetailsDomainModel.emptyValue
    @Published private(set) var isFavorited: Bool = false
    @Published private(set) var showsLearnToShareToolButton: Bool = false
    @Published private(set) var segments: [String] = Array()
    @Published private(set) var selectedSegment: ToolDetailsSegmentType = .about
    @Published private(set) var selectedToolVersion: ToolVersionDomainModel?
    @Published private(set) var outlineContent: String = ""// TODO: Should this be set to something? ~Levi
    
    init(flowDelegate: FlowDelegate, toolId: String, primaryLanguage: AppLanguageDomainModel, parallelLanguage: AppLanguageDomainModel?, selectedLanguageIndex: Int?, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getToolDetailsStringsUseCase: GetToolDetailsStringsUseCase, getToolDetailsUseCase: GetToolDetailsUseCase, getToolDetailsMediaUseCase: GetToolDetailsMediaUseCase, getToolDetailsLearnToShareToolIsAvailableUseCase: GetToolDetailsLearnToShareToolIsAvailableUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase, getToolBannerUseCase: GetToolBannerUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        let primaryLanguage: AppLanguageDomainModel = primaryLanguage
        let parallelLanguage: AppLanguageDomainModel? = parallelLanguage != primaryLanguage ? parallelLanguage : nil
        
        self.flowDelegate = flowDelegate
        self.toolId = toolId
        self.primaryLanguage = primaryLanguage
        self.parallelLanguage = parallelLanguage
        self.selectedLanguageIndex = selectedLanguageIndex
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getToolDetailsStringsUseCase = getToolDetailsStringsUseCase
        self.getToolDetailsUseCase = getToolDetailsUseCase
        self.getToolDetailsMediaUseCase = getToolDetailsMediaUseCase
        self.getToolDetailsLearnToShareToolIsAvailableUseCase = getToolDetailsLearnToShareToolIsAvailableUseCase
        self.toggleToolFavoritedUseCase = toggleToolFavoritedUseCase
        self.getToolBannerUseCase = getToolBannerUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
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
                appLanguage: nil,
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
        
        $appLanguage.dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                getToolDetailsStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (strings: ToolDetailsStringsDomainModel) in
                
                self?.strings = strings
            })
            .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            $toolId,
            $appLanguage.dropFirst(),
            $strings.dropFirst()
        )
        .map { (toolId: String, appLanguage: AppLanguageDomainModel, strings: ToolDetailsStringsDomainModel) in
            
            return Publishers.CombineLatest(
                getToolDetailsUseCase
                    .execute(
                        toolId: toolId,
                        appLanguage: appLanguage,
                        toolPrimaryLanguage: primaryLanguage,
                        toolParallelLanguage: parallelLanguage
                    ),
                Just(strings)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            )
            .eraseToAnyPublisher()
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in
            
        }, receiveValue: { [weak self] (toolDetails: ToolDetailsDomainModel, strings: ToolDetailsStringsDomainModel) in
            
            self?.toolDetails = toolDetails
            self?.analyticsToolAbbreviation = toolDetails.analyticsToolAbbreviation
            self?.isFavorited = toolDetails.isFavorited
                                    
            var segmentTypes: [ToolDetailsSegmentType] = Array()
            segmentTypes.append(.about)
            if !toolDetails.versions.isEmpty {
                segmentTypes.append(.versions)
            }
            
            self?.segmentTypes = segmentTypes
            
            self?.segments = segmentTypes.map({
                switch $0 {
                case .about:
                    return strings.aboutActionTitle
                case .versions:
                    return strings.versionsActionTitle
                }
            })
            
            if self?.selectedToolVersion == nil {
                self?.selectedToolVersion = toolDetails.versions.filter({$0.id == self?.toolId}).first
            }
        })
        .store(in: &cancellables)
        
        $toolId
            .map { (toolId: String) in
                
                getToolDetailsMediaUseCase
                    .execute(toolId: toolId)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .assign(to: &$mediaType)
        
        $toolId
            .map { (toolId: String) in
                
                getToolDetailsLearnToShareToolIsAvailableUseCase
                    .execute(
                        toolId: toolId,
                        primaryLanguage: primaryLanguage,
                        parallelLanguage: parallelLanguage
                    )
            }
            .switchToLatest()
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
            appLanguage: nil,
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
            appLanguage: nil,
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
            .execute(
                toolId: toolId
            )
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (domainModel: ToolIsFavoritedDomainModel) in
                
                self?.isFavorited = domainModel.isFavorited
            })
    }
    
    func segmentTapped(index: Int) {
        
        selectedSegment = segmentTypes[index]
    }
    
    func urlTapped(url: URL) {
           
        flowDelegate?.navigate(step: .urlLinkTappedFromToolDetails(url: url, screenName: getAnalyticsScreenName(analyticsToolAbbreviation: analyticsToolAbbreviation), siteSection: getAnalyticsSiteSection(analyticsToolAbbreviation: analyticsToolAbbreviation), siteSubSection: analyticsSiteSubSection, contentLanguage: nil, contentLanguageSecondary: nil))
    }
    
    func toolVersionTapped(toolVersion: ToolVersionDomainModel) {
        
        toolId = toolVersion.dataModelId
            
        selectedToolVersion = toolVersion

        trackToolVersionTappedAnalytics(toolVersion: toolVersion)
    }
    
    func toolVersionCardWillAppear(toolVersion: ToolVersionDomainModel) -> ToolDetailsVersionsCardViewModel {
        
        return ToolDetailsVersionsCardViewModel(
            toolVersion: toolVersion,
            getToolBannerUseCase: getToolBannerUseCase,
            isSelected: selectedToolVersion?.id == toolVersion.id
        )
    }
}
