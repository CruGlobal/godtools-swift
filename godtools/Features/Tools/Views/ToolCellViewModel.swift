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
    private let attachmentsService: ResourceAttachmentsService
    
    let bannerImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let attachmentsDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let articlesDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let title: String
    let resourceDescription: String
    let parallelLanguageName: ObservableValue = ObservableValue(value: "")
    let isFavorited: ObservableValue = ObservableValue(value: false)
    
    required init(resource: ResourceModel, resourcesService: ResourcesService, favoritedResourcesService: FavoritedResourcesService, languageSettingsService: LanguageSettingsService) {
        
        self.resource = resource
        self.resourcesService = resourcesService
        self.languageSettingsService = languageSettingsService
        self.title = resource.name
        self.resourceDescription = resource.attrCategory
        self.attachmentsService = resourcesService.attachmentsService
        
        super.init()
        
        reloadBannerImage()
        setupBinding()
        
        favoritedResourcesService.isFavorited(resourceId: resource.id) { [weak self] (isFavorited: Bool) in
            self?.isFavorited.accept(value: isFavorited)
        }        
    }
    
    deinit {
        attachmentsService.progress.removeObserver(self)
        attachmentsService.completed.removeObserver(self)
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
           
        attachmentsService.progress.addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async { [weak self] in
                self?.attachmentsDownloadProgress.accept(value: progress)
            }
        }
        
        attachmentsService.completed.addObserver(self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.reloadBannerImage()
            }
        }
        
        languageSettingsService.parallelLanguage.addObserver(self) { [weak self] (parallelLanguage: LanguageModel?) in
            self?.reloadParallelLanguageName()
        }
    }
}
