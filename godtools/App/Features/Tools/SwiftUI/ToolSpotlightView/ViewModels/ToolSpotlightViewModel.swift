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
    
    private let dataDownloader: InitialDataDownloader
    private let deviceAttachmentBanners: DeviceAttachmentBanners
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private weak var delegate: ToolSpotlightDelegate?
    
    // MARK: - Published
    
    @Published var spotlightTitle: String = ""
    @Published var spotlightSubtitle: String = ""
    @Published var spotlightTools: [ResourceModel] = []
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, deviceAttachmentBanners: DeviceAttachmentBanners, favoritedResourcesCache: FavoritedResourcesCache, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, delegate: ToolSpotlightDelegate?) {
        self.dataDownloader = dataDownloader
        self.deviceAttachmentBanners = deviceAttachmentBanners
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.delegate = delegate
        
        super.init()
        
        setTitleText()
        setupBinding()
    }
    
    deinit {
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
        languageSettingsService.primaryLanguage.removeObserver(self)
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
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.setTitleText()
            }
        }
    }
    
    private func reloadResourcesFromCache() {
        spotlightTools = dataDownloader.resourcesCache.getAllVisibleToolsSorted(andFilteredBy: { $0.attrSpotlight })
    }
    
    private func setTitleText() {
        let languageBundle = localizationServices.bundleLoader.bundleForPrimaryLanguageOrFallback(in: languageSettingsService)
        spotlightTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "allTools.spotlight.title")
        spotlightSubtitle = localizationServices.stringForBundle(bundle: languageBundle, key: "allTools.spotlight.description")
    }
}

// MARK: - Public

extension ToolSpotlightViewModel {
    
    func cardViewModel(for tool: ResourceModel) -> BaseToolCardViewModel {
        return ToolCardViewModel(
            cardType: .spotlight,
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
