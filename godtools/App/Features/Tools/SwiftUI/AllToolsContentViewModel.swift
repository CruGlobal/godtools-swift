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
    
    // MARK: - Published
    
    @Published var tools: [ResourceModel] = []
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, deviceAttachmentBanners: DeviceAttachmentBanners, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices) {
        self.dataDownloader = dataDownloader
        self.deviceAttachmentBanners = deviceAttachmentBanners
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        
        super.init()
        
        setupBinding()
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
            localizationServices: localizationServices)
        
        return ToolCardViewModel(
            getBannerImageUseCase: getBannerImageUseCase,
            getToolDataUseCase: getToolDataUseCase
        )
    }
}

// MARK: - Private

extension AllToolsContentViewModel {
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
//                self?.isLoading.accept(value: !cachedResourcesAvailable)
                if cachedResourcesAvailable {
                    self?.reloadResourcesFromCache()
                }
            }
        }
        
        dataDownloader.resourcesUpdatedFromRemoteDatabase.addObserver(self) { [weak self] (error: InitialDataDownloaderError?) in
            DispatchQueue.main.async { [weak self] in
//                self?.didEndRefreshing.accept()
                if error == nil {
                    self?.reloadResourcesFromCache()
                }
            }
        }
        
//        favoritedResourcesCache.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
//            DispatchQueue.main.async { [weak self] in
//                self?.reloadTool(resourceId: resourceId)
//            }
//        }
//
//        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
//            DispatchQueue.main.async { [weak self] in
//                self?.reloadTool(resourceId: resourceId)
//            }
//        }
    }
    
    private func reloadResourcesFromCache() {
        let sortedResources: [ResourceModel] = dataDownloader.resourcesCache.getSortedResources()
        let resources: [ResourceModel] = sortedResources.filter({
            let resourceType: ResourceType = $0.resourceTypeEnum
            return (resourceType == .tract || resourceType == .article || resourceType == .chooseYourOwnAdventure) && !$0.isHidden
        })
        
        tools = resources
//        isLoading.accept(value: false)
    }
}
