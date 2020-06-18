//
//  ToolCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolCellViewModel: NSObject, ToolCellViewModelType {
    
    private let resource: ResourceModel
    private let resourcesService: ResourcesService
    private let languageSettingsCache: LanguageSettingsCacheType
    private let translationService: ResourceTranslationsService
    
    let bannerImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let title: String
    let resourceDescription: String
    let parallelLanguageName: ObservableValue = ObservableValue(value: "")
    let isFavorited: ObservableValue = ObservableValue(value: false)
    
    required init(resource: ResourceModel, resourcesService: ResourcesService, favoritedResourcesCache: RealmFavoritedResourcesCache, languageSettingsCache: LanguageSettingsCacheType) {
        
        self.resource = resource
        self.resourcesService = resourcesService
        self.languageSettingsCache = languageSettingsCache
        self.title = resource.name
        self.resourceDescription = resource.attrCategory
        self.translationService = resourcesService.translationsServices.getService(resourceId: resource.id)
        
        super.init()
        
        reloadBannerImage()
        reloadParallelLanguageName()
        setupBinding()
        
        favoritedResourcesCache.isFavorited(resourceId: resource.id) { [weak self] (isFavorited: Bool) in
            self?.isFavorited.accept(value: isFavorited)
        }
    }
    
    deinit {
        resourcesService.attachmentsService.completed.removeObserver(self)
        translationService.progress.removeObserver(self)
        languageSettingsCache.parallelLanguageId.removeObserver(self)
    }
    
    private func reloadBannerImage() {
        resourcesService.attachmentsService.getAttachmentBanner(attachmentId: resource.attrBanner) { [weak self] (image: UIImage?) in
            self?.bannerImage.accept(value: image)
        }
    }
    
    private func reloadParallelLanguageName() {

        let userParallelLanguageId: String = languageSettingsCache.parallelLanguageId.value ?? ""
        let supportsParallelLanguage: Bool = resource.languageIds.contains(userParallelLanguageId)
        
        resourcesService.realmResourcesCache.getLanguage(id: userParallelLanguageId) { [weak self] (language: LanguageModel?) in
            
            guard let language = language else {
                self?.parallelLanguageName.accept(value: "")
                return
            }
            
            if supportsParallelLanguage {
                let name: String = "✓ " + LanguageNameViewModel(language: language).name
                self?.parallelLanguageName.accept(value: name)
            }
            else {
                self?.parallelLanguageName.accept(value: "")
            }
        }
    }
    
    private func setupBinding() {
        
        resourcesService.attachmentsService.completed.addObserver(self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.reloadBannerImage()
            }
        }
        
        translationService.progress.addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async { [weak self] in
                self?.translationDownloadProgress.accept(value: progress)
            }
        }
        
        languageSettingsCache.parallelLanguageId.addObserver(self) { [weak self] (parallelLanguageId: String?) in
            self?.reloadParallelLanguageName()
        }
    }
}
