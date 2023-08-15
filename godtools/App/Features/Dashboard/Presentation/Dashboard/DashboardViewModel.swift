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

class DashboardViewModel: ObservableObject {
    
    private let initialDataDownloader: InitialDataDownloader
    private let translationsRepository: TranslationsRepository
    private let attachmentsRepository: AttachmentsRepository
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
    private let getShouldShowLanguageSettingsBarButtonUseCase: GetShouldShowLanguageSettingsBarButtonUseCase
    private let getSpotlightToolsUseCase: GetSpotlightToolsUseCase
    private let getToolCategoriesUseCase: GetToolCategoriesUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase
    private let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase
    
    private var chooseLanguageButton: UIBarButtonItem?
    
    private var unwrappedFlowDelegate: FlowDelegate {
        guard let flowDelegate = self.flowDelegate else {
            assertionFailure("FlowDelegate should not be nil.")
            return self.flowDelegate!
        }
        return flowDelegate
    }
    
    private weak var flowDelegate: FlowDelegate?
    
    let shouldShowLanguageSettingsBarButtonItemPublisher = CurrentValueSubject<(shouldShowButton: Bool, barButtonItem: UIBarButtonItem?), Never>((false, nil))
    
    @Published var allToolsTabTitle: String
    @Published var favoritesTabTitle: String
    @Published var lessonsTabTitle: String
    @Published var selectedTab: DashboardTabTypeDomainModel {
        didSet {
            tabChanged()
        }
    }
    
    lazy var allToolsViewModel: AllToolsContentViewModel = {
        AllToolsContentViewModel(
            flowDelegate: unwrappedFlowDelegate,
            dataDownloader: initialDataDownloader,
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
            attachmentsRepository: attachmentsRepository,
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
            getLessonsUseCase: getLessonsUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase,
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase,
            attachmentsRepository: attachmentsRepository
        )
    }()
    
    required init(startingTab: DashboardTabTypeDomainModel, flowDelegate: FlowDelegate, initialDataDownloader: InitialDataDownloader, translationsRepository: TranslationsRepository, attachmentsRepository: AttachmentsRepository, localizationServices: LocalizationServices, favoritingToolMessageCache: FavoritingToolMessageCache, analytics: AnalyticsContainer, disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase, getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getAllToolsUseCase: GetAllToolsUseCase, getBannerImageUseCase: GetBannerImageUseCase, getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getLessonsUseCase: GetLessonsUseCase, getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getShouldShowLanguageSettingsBarButtonUseCase: GetShouldShowLanguageSettingsBarButtonUseCase, getSpotlightToolsUseCase: GetSpotlightToolsUseCase, getToolCategoriesUseCase: GetToolCategoriesUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase) {
        
        self.flowDelegate = flowDelegate
        self.initialDataDownloader = initialDataDownloader
        self.translationsRepository = translationsRepository
        self.attachmentsRepository = attachmentsRepository
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
        self.getShouldShowLanguageSettingsBarButtonUseCase = getShouldShowLanguageSettingsBarButtonUseCase
        self.getSpotlightToolsUseCase = getSpotlightToolsUseCase
        self.getToolCategoriesUseCase = getToolCategoriesUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.removeToolFromFavoritesUseCase = removeToolFromFavoritesUseCase
        self.toggleToolFavoritedUseCase = toggleToolFavoritedUseCase
        
        allToolsTabTitle = localizationServices.stringForSystemElseEnglish(key: "tool_menu_item.tools")
        favoritesTabTitle = localizationServices.stringForSystemElseEnglish(key: "my_tools")
        lessonsTabTitle = localizationServices.stringForSystemElseEnglish(key: "tool_menu_item.lessons")
        selectedTab = startingTab
        
        tabChanged()
    }
}

// MARK: - Private

extension DashboardViewModel {
    
    private func tabChanged() {
        
        let shouldShowLanguageSettingsButton = getShouldShowLanguageSettingsBarButtonUseCase.getShouldShowLanguageSettingsBarButton(for: selectedTab)
        
        let languageButtonCurrentlyShowing = shouldShowLanguageSettingsBarButtonItemPublisher.value.shouldShowButton
        if languageButtonCurrentlyShowing != shouldShowLanguageSettingsButton {
            
            publishNewLanguageSettingsBarButtonItemState(shouldShowButton: shouldShowLanguageSettingsButton)
        }
    }
    
    private func publishNewLanguageSettingsBarButtonItemState(shouldShowButton: Bool) {
        
        if shouldShowButton {

            chooseLanguageButton = createLanguageBarButtonItem()
            shouldShowLanguageSettingsBarButtonItemPublisher.send((true, chooseLanguageButton))
            
        } else {
            
            shouldShowLanguageSettingsBarButtonItemPublisher.send((false, chooseLanguageButton))
            chooseLanguageButton = nil
        }
    }
    
    private func createLanguageBarButtonItem() -> UIBarButtonItem {
        let languageBarButtonItem = UIBarButtonItem()
        languageBarButtonItem.image = ImageCatalog.navLanguage.uiImage
        languageBarButtonItem.tintColor = .white
        languageBarButtonItem.target = self
        languageBarButtonItem.action = #selector(languageBarButtonItemTapped)
        
        return languageBarButtonItem
    }
}

// MARK: - Inputs

extension DashboardViewModel {
    
    @objc func menuTapped() {
        flowDelegate?.navigate(step: .menuTappedFromTools)
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
