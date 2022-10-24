//
//  DashboardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 10/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI

class DashboardViewModel: ObservableObject {
    
    private let initialDataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let favoritingToolMessageCache: FavoritingToolMessageCache
    private let analytics: AnalyticsContainer
    
    private let disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase
    private let getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase
    private let getAllToolsUseCase: GetAllToolsUseCase
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getLessonsUseCase: GetLessonsUseCase
    private let getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSpotlightToolsUseCase: GetSpotlightToolsUseCase
    private let getToolCategoriesUseCase: GetToolCategoriesUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase
    private let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase
    
    private weak var flowDelegate: FlowDelegate?
    private var unwrappedFlowDelegate: FlowDelegate {
        guard let flowDelegate = self.flowDelegate else {
            assertionFailure("FlowDelegate should not be nil.")
            return self.flowDelegate!
        }
        return flowDelegate
    }
    
    private var chooseLanguageButton: UIBarButtonItem?
    var shouldShowLanguageSettingsBarButtonItemPublisher = CurrentValueSubject<(Bool, UIBarButtonItem?), Never>((false, nil))
    
    @Published var allToolsTabTitle: String
    @Published var favoritesTabTitle: String
    @Published var lessonsTabTitle: String
    @Published var selectedTab: DashboardTabType {
        didSet {
            tabChanged()
        }
    }
    
    lazy var allToolsViewModel: AllToolsContentViewModel = {
        AllToolsContentViewModel(
            flowDelegate: unwrappedFlowDelegate,
            dataDownloader: initialDataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            favoritingToolMessageCache: favoritingToolMessageCache,
            analytics: analytics,
            getAllToolsUseCase: getAllToolsUseCase,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase,
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase,
            getSpotlightToolsUseCase: getSpotlightToolsUseCase,
            getToolCategoriesUseCase: getToolCategoriesUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            toggleToolFavoritedUseCase: toggleToolFavoritedUseCase
        )
    }()
    
    lazy var favoritesViewModel: FavoritesContentViewModel = {
        let favoritesViewModel = FavoritesContentViewModel(
            flowDelegate: unwrappedFlowDelegate,
            dataDownloader: initialDataDownloader,
            localizationServices: localizationServices,
            analytics: analytics,
            disableOptInOnboardingBannerUseCase: disableOptInOnboardingBannerUseCase,
            getAllFavoritedToolsUseCase: getAllFavoritedToolsUseCase,
            getBannerImageUseCase: getBannerImageUseCase,
            getFeaturedLessonsUseCase: getFeaturedLessonsUseCase,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getOptInOnboardingBannerEnabledUseCase: getOptInOnboardingBannerEnabledUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase,
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            removeToolFromFavoritesUseCase: removeToolFromFavoritesUseCase
        )
        
        favoritesViewModel.setDelegate(delegate: self)
        
        return favoritesViewModel
    }()
    
    lazy var lessonsViewModel: LessonsViewModel = {
        LessonsViewModel(
            flowDelegate: unwrappedFlowDelegate,
            dataDownloader: initialDataDownloader,
            localizationServices: localizationServices,
            analytics: analytics,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityUseCase:
            getLanguageAvailabilityUseCase,
            getLessonsUseCase: getLessonsUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase,
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase
        )
    }()
    
    required init(startingTab: DashboardTabType, flowDelegate: FlowDelegate, initialDataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritingToolMessageCache: FavoritingToolMessageCache, analytics: AnalyticsContainer, disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase, getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getAllToolsUseCase: GetAllToolsUseCase, getBannerImageUseCase: GetBannerImageUseCase, getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getLessonsUseCase: GetLessonsUseCase, getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSpotlightToolsUseCase: GetSpotlightToolsUseCase, getToolCategoriesUseCase: GetToolCategoriesUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase, fontService: FontService) {
        
        self.flowDelegate = flowDelegate
        self.initialDataDownloader = initialDataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.analytics = analytics
        
        self.disableOptInOnboardingBannerUseCase = disableOptInOnboardingBannerUseCase
        self.getAllFavoritedToolsUseCase = getAllFavoritedToolsUseCase
        self.getAllToolsUseCase = getAllToolsUseCase
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getFeaturedLessonsUseCase = getFeaturedLessonsUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getLessonsUseCase = getLessonsUseCase
        self.getOptInOnboardingBannerEnabledUseCase = getOptInOnboardingBannerEnabledUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSpotlightToolsUseCase = getSpotlightToolsUseCase
        self.getToolCategoriesUseCase = getToolCategoriesUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.removeToolFromFavoritesUseCase = removeToolFromFavoritesUseCase
        self.toggleToolFavoritedUseCase = toggleToolFavoritedUseCase
        
        allToolsTabTitle = localizationServices.stringForMainBundle(key: "tool_menu_item.tools")
        favoritesTabTitle = localizationServices.stringForMainBundle(key: "my_tools")
        lessonsTabTitle = localizationServices.stringForMainBundle(key: "tool_menu_item.lessons")
        selectedTab = startingTab
    }
}

// MARK: - Public

extension DashboardViewModel {
    
    @objc func menuTapped() {
        flowDelegate?.navigate(step: .menuTappedFromTools)
    }
    
    func tabChanged() {
        
        let shouldShowLanguageSettingsButton: Bool
        switch selectedTab {
        case .favorites, .allTools:
            shouldShowLanguageSettingsButton = true
        case .lessons:
            shouldShowLanguageSettingsButton = false
        }
        
        if shouldShowLanguageSettingsBarButtonItemPublisher.value.0 != shouldShowLanguageSettingsButton {
            
            if shouldShowLanguageSettingsButton {
    
                chooseLanguageButton = UIBarButtonItem()
                chooseLanguageButton?.image = ImageCatalog.navLanguage.uiImage
                chooseLanguageButton?.tintColor = .white
                chooseLanguageButton?.target = self
                chooseLanguageButton?.action = #selector(languageBarButtonItemTapped)
                
                shouldShowLanguageSettingsBarButtonItemPublisher.send((true, chooseLanguageButton))
                
            } else {
                
                shouldShowLanguageSettingsBarButtonItemPublisher.send((false, chooseLanguageButton))
                chooseLanguageButton = nil
            }
        }

    }
            
    @objc func languageBarButtonItemTapped() {
        flowDelegate?.navigate(step: .languageSettingsTappedFromTools)
    }
}

// MARK: - FavoritesContentViewModelDelegate

extension DashboardViewModel: FavoritesContentViewModelDelegate {
    
    func favoriteToolsViewGoToToolsTapped() {
        flowDelegate?.navigate(step: .allToolsTappedFromFavoritedTools)
    }
}
