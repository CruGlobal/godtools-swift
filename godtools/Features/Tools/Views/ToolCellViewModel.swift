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
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    
    let bannerImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let attachmentsDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let articlesDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let title: String
    let resourceDescription: String
    let parallelLanguageName: ObservableValue = ObservableValue(value: "")
    let isFavorited: ObservableValue = ObservableValue(value: false)
    
    required init(resource: ResourceModel, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, favoritedResourcesService: FavoritedResourcesService) {
        
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.title = resource.name
        self.resourceDescription = resource.attrCategory
        
        super.init()
        
        reloadBannerImage()
        setupBinding()
        
        favoritedResourcesService.isFavorited(resourceId: resource.id) { [weak self] (isFavorited: Bool) in
            self?.isFavorited.accept(value: isFavorited)
        }        
    }
    
    deinit {
        dataDownloader.attachmentsDownloaderStarted.removeObserver(self)
        dataDownloader.attachmentsDownloaderProgress.removeObserver(self)
        dataDownloader.attachmentDownloaded.removeObserver(self)
        dataDownloader.attachmentsDownloaderCompleted.removeObserver(self)
        languageSettingsService.parallelLanguage.removeObserver(self)
    }
    
    private func reloadBannerImage() {
        dataDownloader.attachmentsFileCache.getAttachmentBanner(attachmentId: resource.attrBanner) { [weak self] (image: UIImage?) in
            self?.bannerImage.accept(value: image)
        }
    }
    
    private func reloadParallelLanguageName() {

        let userParallelLanguageId: String = languageSettingsService.parallelLanguage.value?.id ?? ""
        let supportsParallelLanguage: Bool = resource.languageIds.contains(userParallelLanguageId)
        
        guard let parallelLanguage = languageSettingsService.parallelLanguage.value else {
            parallelLanguageName.accept(value: "")
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
           
        dataDownloader.attachmentsDownloaderProgress.addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async { [weak self] in
                self?.attachmentsDownloadProgress.accept(value: progress)
            }
        }
        
        dataDownloader.attachmentDownloaded.addObserver(self) { [weak self] (result: Result<AttachmentFile, AttachmentsDownloaderError>) in
            DispatchQueue.main.async { [weak self] in
                guard let attachmentId = self?.resource.attrBanner else {
                    return
                }
                switch result {
                case .success(let attachmentFile):
                    if attachmentFile.relatedAttachmentIds.contains(attachmentId) {
                        self?.reloadBannerImage()
                    }
                case .failure( _):
                    break
                }
            }
        }
        
        languageSettingsService.parallelLanguage.addObserver(self) { [weak self] (parallelLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadParallelLanguageName()
            }
        }
    }
}
