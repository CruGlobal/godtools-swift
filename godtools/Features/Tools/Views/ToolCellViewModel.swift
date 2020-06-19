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
    private let languageSettingsService: LanguageSettingsService
    private let translationsServices: ResourceTranslationsServices
    
    let bannerImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let title: String
    let resourceDescription: String
    let parallelLanguageName: ObservableValue = ObservableValue(value: "")
    let isFavorited: ObservableValue = ObservableValue(value: false)
    
    required init(resource: ResourceModel, resourcesService: ResourcesService, favoritedResourcesCache: RealmFavoritedResourcesCache, languageSettingsService: LanguageSettingsService) {
        
        self.resource = resource
        self.resourcesService = resourcesService
        self.languageSettingsService = languageSettingsService
        self.title = resource.name
        self.resourceDescription = resource.attrCategory
        self.translationsServices = resourcesService.translationsServices
        
        super.init()
        
        reloadBannerImage()
        setupBinding()
        
        favoritedResourcesCache.isFavorited(resourceId: resource.id) { [weak self] (isFavorited: Bool) in
            self?.isFavorited.accept(value: isFavorited)
        }
    }
    
    deinit {
        resourcesService.attachmentsService.completed.removeObserver(self)
        translationsServices.progress(resource: resource).removeObserver(self)
        languageSettingsService.parallelLanguage.removeObserver(self)
    }
    
    private func reloadBannerImage() {
        resourcesService.attachmentsService.getAttachmentBanner(attachmentId: resource.attrBanner) { [weak self] (image: UIImage?) in
            self?.bannerImage.accept(value: image)
        }
    }
    
    private func reloadParallelLanguageName() {

        let userParallelLanguageId: String = languageSettingsService.parallelLanguage.value?.id ?? ""
        let supportsParallelLanguage: Bool = resource.languageIds.contains(userParallelLanguageId)
        
        guard let parallelLanguage = languageSettingsService.parallelLanguage.value else {
            return
        }
        
        if supportsParallelLanguage {
            let name: String = "✓ " + LanguageNameTranslationViewModel(language: parallelLanguage, languageSettingsService: languageSettingsService, shouldFallbackToPrimaryLanguageLocale: false).name
            parallelLanguageName.accept(value: name)
        }
        else {
            parallelLanguageName.accept(value: "")
        }
    }
    
    private func setupBinding() {
        
        resourcesService.attachmentsService.completed.addObserver(self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.reloadBannerImage()
            }
        }
        
        translationsServices.progress(resource: resource).addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async { [weak self] in
                self?.translationDownloadProgress.accept(value: progress)
            }
        }
        
        languageSettingsService.parallelLanguage.addObserver(self) { [weak self] (parallelLanguage: LanguageModel?) in
            self?.reloadParallelLanguageName()
        }
    }
}
