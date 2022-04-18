//
//  AllToolsContentViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AllToolsContentViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private let dataDownloader: InitialDataDownloader
    private let deviceAttachmentBanners: DeviceAttachmentBanners
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let favoritedResourcesCache: FavoritedResourcesCache
    
    // MARK: - Published
    
    @Published var tools: [ResourceModel] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, deviceAttachmentBanners: DeviceAttachmentBanners, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritedResourcesCache: FavoritedResourcesCache) {
        self.dataDownloader = dataDownloader
        self.deviceAttachmentBanners = deviceAttachmentBanners
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritedResourcesCache = favoritedResourcesCache
        
        super.init()
        
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
    }
}

// MARK: - Public

extension AllToolsContentViewModel {
    
    func cardViewModel(for tool: ResourceModel) -> ToolCardViewModel {
        let getBannerImageUseCase = DefaultGetBannerImageUseCase(
            resource: tool,
            dataDownloader: dataDownloader,
            deviceAttachmentBanners: deviceAttachmentBanners
        )
        let getToolDataUseCase = DefaultGetToolDataUseCase(
            resource: tool,
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices
        )
        let getLanguageNameUseCase = DefaultGetLanguageNameUseCase(
            resource: tool,
            localizationServices: localizationServices
        )
        
        return ToolCardViewModel(
            resourceId: tool.id,
            getBannerImageUseCase: getBannerImageUseCase,
            getToolDataUseCase: getToolDataUseCase,
            getLanguageNameUseCase: getLanguageNameUseCase,
            favoritedResourcesCache: favoritedResourcesCache,
            languageSettingsService: languageSettingsService
        )
    }
    
    func refreshTools() {
        dataDownloader.downloadInitialData()
    }
}

// MARK: - Private

extension AllToolsContentViewModel {
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.isLoading = !cachedResourcesAvailable
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
        let resources: [ResourceModel] = sortedResources.filter({
            let resourceType: ResourceType = $0.resourceTypeEnum
            return (resourceType == .tract || resourceType == .article || resourceType == .chooseYourOwnAdventure) && !$0.isHidden
        })
        
        tools = resources
        isLoading = false
    }
}
