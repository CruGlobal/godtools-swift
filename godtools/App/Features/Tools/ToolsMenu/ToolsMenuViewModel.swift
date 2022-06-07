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
    private let deviceAttachmentBanners: DeviceAttachmentBanners
    private let favoritingToolMessageCache: FavoritingToolMessageCache
    private let analytics: AnalyticsContainer
    private let getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase
    private let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitleFont: UIFont
        
    required init(flowDelegate: FlowDelegate, initialDataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritedResourcesCache: FavoritedResourcesCache, deviceAttachmentBanners: DeviceAttachmentBanners, favoritingToolMessageCache: FavoritingToolMessageCache, analytics: AnalyticsContainer, getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase, openTutorialCalloutCache: OpenTutorialCalloutCacheType, fontService: FontService) {
        
        self.flowDelegate = flowDelegate
        self.initialDataDownloader = initialDataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritedResourcesCache = favoritedResourcesCache
        self.deviceAttachmentBanners = deviceAttachmentBanners
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.analytics = analytics
        self.getTutorialIsAvailableUseCase = getTutorialIsAvailableUseCase
        self.openTutorialCalloutCache = openTutorialCalloutCache
        self.navTitleFont = fontService.getFont(size: 17, weight: .semibold)
    }
    
    private func getFlowDelegate() -> FlowDelegate {
        guard let flowDelegate = self.flowDelegate else {
            assertionFailure("FlowDelegate should not be nil.")
            return self.flowDelegate!
        }
        return flowDelegate
    }
    
    func lessonsWillAppear() -> LessonsListViewModelType {
        return LessonsListViewModel(
            flowDelegate: getFlowDelegate(),
            dataDownloader: initialDataDownloader,
            languageSettingsService: languageSettingsService,
            analytics: analytics
        )
    }
    
    func favoritedToolsWillAppear() -> FavoritedToolsViewModelType {

        return FavoritedToolsViewModel(
            flowDelegate: getFlowDelegate(),
            dataDownloader: initialDataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            favoritedResourcesCache: favoritedResourcesCache,
            deviceAttachmentBanners: deviceAttachmentBanners,
            analytics: analytics,
            getTutorialIsAvailableUseCase: getTutorialIsAvailableUseCase,
            openTutorialCalloutCache: openTutorialCalloutCache
        )
    }
    
    func allToolsWillAppear() -> AllToolsContentViewModel {
        return AllToolsContentViewModel(
            flowDelegate: getFlowDelegate(),
            dataDownloader: initialDataDownloader,
            deviceAttachmentBanners: deviceAttachmentBanners,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            favoritedResourcesCache: favoritedResourcesCache,
            favoritingToolMessageCache: favoritingToolMessageCache,
            analytics: analytics
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
