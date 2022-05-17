//
//  ToolSpotlightViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol ToolSpotlightDelegate: AnyObject {
    func spotlightCardTapped(resource: ResourceModel)
}

class ToolSpotlightViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    let spotlightTitle: String
    let spotlightSubtitle: String
    private weak var delegate: ToolSpotlightDelegate?
    
    private let dataDownloader: InitialDataDownloader
    private let deviceAttachmentBanners: DeviceAttachmentBanners
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    
    // MARK: - Published
    
    @Published var spotlightTools: [ResourceModel] = []
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, deviceAttachmentBanners: DeviceAttachmentBanners, favoritedResourcesCache: FavoritedResourcesCache, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, delegate: ToolSpotlightDelegate?) {
        self.dataDownloader = dataDownloader
        self.deviceAttachmentBanners = deviceAttachmentBanners
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.delegate = delegate
        
        spotlightTitle = localizationServices.stringForMainBundle(key: "allTools.spotlight.title")
        spotlightSubtitle = localizationServices.stringForMainBundle(key: "allTools.spotlight.description")
        
        super.init()
        
        setupBinding()
    }
    
    deinit {
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
    }
}

// MARK: - Private

extension ToolSpotlightViewModel {
    
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if cachedResourcesAvailable {
                    self.reloadResourcesFromCache()
                }
            }
        }
        
        dataDownloader.resourcesUpdatedFromRemoteDatabase.addObserver(self) { [weak self] (error: InitialDataDownloaderError?) in
            DispatchQueue.main.async { [weak self] in
                if error == nil {
                    self?.reloadResourcesFromCache()
                }
            }
        }
    }
    
    private func reloadResourcesFromCache() {
        let sortedResources: [ResourceModel] = dataDownloader.resourcesCache.getSortedResources()
        let spotlightResources: [ResourceModel] = sortedResources.filter({
            let resourceType: ResourceType = $0.resourceTypeEnum
            return (resourceType == .tract || resourceType == .article || resourceType == .chooseYourOwnAdventure) && !$0.isHidden && $0.attrSpotlight
        })
        
        spotlightTools = spotlightResources
    }
}

// MARK: - Public

extension ToolSpotlightViewModel {
    
    func cardViewModel(for tool: ResourceModel) -> BaseToolCardViewModel {
        return ToolCardViewModel(
            resource: tool,
            dataDownloader: dataDownloader,
            deviceAttachmentBanners: deviceAttachmentBanners,
            favoritedResourcesCache: favoritedResourcesCache,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices
        )
    }
    
    func spotlightToolTapped(resource: ResourceModel) {
        delegate?.spotlightCardTapped(resource: resource)
    }
}
