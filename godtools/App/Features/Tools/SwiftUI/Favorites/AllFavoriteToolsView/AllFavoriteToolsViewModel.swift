//
//  AllFavoriteToolsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AllFavoriteToolsViewModel: BaseFavoriteToolsViewModel {
    
    // MARK: - Properties
    
    private weak var flowDelegate: FlowDelegate?
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, deviceAttachmentBanners: DeviceAttachmentBanners, favoritedResourcesCache: FavoritedResourcesCache, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, flowDelegate: FlowDelegate?) {
        self.flowDelegate = flowDelegate
        
        super.init(cardType: .standardWithNavButtons, dataDownloader: dataDownloader, deviceAttachmentBanners: deviceAttachmentBanners, favoritedResourcesCache: favoritedResourcesCache, languageSettingsService: languageSettingsService, localizationServices: localizationServices, delegate: nil, toolCardDelegate: nil)
    }
    
    // MARK: - Overrides
    
    override func cardViewModel(for tool: ResourceModel) -> BaseToolCardViewModel {
        return ToolCardViewModel(
            cardType: cardType,
            resource: tool,
            dataDownloader: dataDownloader,
            deviceAttachmentBanners: deviceAttachmentBanners,
            favoritedResourcesCache: favoritedResourcesCache,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            delegate: self
        )
    }
    
    override func removeFavoritedResource(resourceIds: [String]) {
        super.removeFavoritedResource(resourceIds: resourceIds)
        
        if tools.isEmpty {
            closePage()
        }
    }
}

// MARK: - Public

extension AllFavoriteToolsViewModel {
    
    func backButtonTapped() {
        closePage()
    }
}

// MARK: - Private

extension AllFavoriteToolsViewModel {
    
    func closePage() {
        flowDelegate?.navigate(step: .backTappedFromAllFavoriteTools)
    }
}

// MARK: - ToolCardDelegate

extension AllFavoriteToolsViewModel: ToolCardDelegate {
    func toolCardTapped(resource: ResourceModel) {
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
    }
    
    func toolFavoriteButtonTapped(resource: ResourceModel) {
        let removedHandler = CallbackHandler { [weak self] in
            guard let self = self else { return }
            
            self.favoritedResourcesCache.removeFromFavorites(resourceId: resource.id)
        }
        flowDelegate?.navigate(step: .unfavoriteToolTappedFromFavoritedTools(resource: resource, removeHandler: removedHandler))
    }
    
    func toolDetailsButtonTapped(resource: ResourceModel) {
        flowDelegate?.navigate(step: .aboutToolTappedFromFavoritedTools(resource: resource))
    }
    
    func openToolButtonTapped(resource: ResourceModel) {
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
    }
}
