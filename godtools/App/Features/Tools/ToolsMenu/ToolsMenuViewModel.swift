//
//  ToolsMenuViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolsMenuViewModel: ToolsMenuViewModelType {
    
    private let initialDataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let favoritingToolMessageCache: FavoritingToolMessageCache
    private let analytics: AnalyticsContainer
    
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase
    private let disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase
    private let getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitleFont: UIFont
        
    required init(flowDelegate: FlowDelegate, initialDataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritedResourcesCache: FavoritedResourcesCache, favoritingToolMessageCache: FavoritingToolMessageCache, analytics: AnalyticsContainer, getBannerImageUseCase: GetBannerImageUseCase, getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase, disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase, getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, fontService: FontService) {
        
        self.flowDelegate = flowDelegate
        self.initialDataDownloader = initialDataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritedResourcesCache = favoritedResourcesCache
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.analytics = analytics
        
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getOptInOnboardingBannerEnabledUseCase = getOptInOnboardingBannerEnabledUseCase
        self.disableOptInOnboardingBannerUseCase = disableOptInOnboardingBannerUseCase
        self.getLanguageAvailabilityStringUseCase = getLanguageAvailabilityStringUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        
        self.navTitleFont = fontService.getFont(size: 17, weight: .semibold)
    }
    
    private func getFlowDelegate() -> FlowDelegate {
        guard let flowDelegate = self.flowDelegate else {
            assertionFailure("FlowDelegate should not be nil.")
            return self.flowDelegate!
        }
        return flowDelegate
    }
    
    func lessonsWillAppear() -> LessonsContentViewModel {
        return LessonsContentViewModel(
            flowDelegate: getFlowDelegate(),
            dataDownloader: initialDataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            analytics: analytics,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase
        )
    }
    
    func favoritedToolsWillAppear() -> FavoritesContentViewModel {
        return FavoritesContentViewModel(
            flowDelegate: getFlowDelegate(),
            dataDownloader: initialDataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            favoritedResourcesCache: favoritedResourcesCache,
            analytics: analytics,
            getBannerImageUseCase: getBannerImageUseCase,
            getOptInOnboardingBannerEnabledUseCase: getOptInOnboardingBannerEnabledUseCase,
            disableOptInOnboardingBannerUseCase: disableOptInOnboardingBannerUseCase,
            getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase
        )
    }
    
    func allToolsWillAppear() -> AllToolsContentViewModel {
        return AllToolsContentViewModel(
            flowDelegate: getFlowDelegate(),
            dataDownloader: initialDataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            favoritedResourcesCache: favoritedResourcesCache,
            favoritingToolMessageCache: favoritingToolMessageCache,
            analytics: analytics,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase
        )
    }
    
    func toolbarWillAppear() -> ToolsMenuToolbarViewModelType {
        return ToolsMenuToolbarViewModel(localizationServices: localizationServices)
    }
    
    func menuTapped() {
        flowDelegate?.navigate(step: .menuTappedFromTools)
    }
    
    func languageTapped() {
        flowDelegate?.navigate(step: .languageSettingsTappedFromTools)
    }
}
