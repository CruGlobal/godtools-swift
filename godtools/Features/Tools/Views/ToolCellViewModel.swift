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
    private let translateLanguageNameViewModel: TranslateLanguageNameViewModel
    private let fetchLanguageTranslationViewModel: FetchLanguageTranslationViewModel
    
    let bannerImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let attachmentsDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let articlesDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let title: ObservableValue<String> = ObservableValue(value: "")
    let resourceDescription: ObservableValue<String> = ObservableValue(value: "")
    let parallelLanguageName: ObservableValue = ObservableValue(value: "")
    let isFavorited: ObservableValue = ObservableValue(value: false)
    
    required init(resource: ResourceModel, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, favoritedResourcesCache: FavoritedResourcesCache, fetchLanguageTranslationViewModel: FetchLanguageTranslationViewModel) {
        
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.translateLanguageNameViewModel = TranslateLanguageNameViewModel(languageSettingsService: languageSettingsService, shouldFallbackToPrimaryLanguageLocale: false)
        self.fetchLanguageTranslationViewModel = fetchLanguageTranslationViewModel
        
        super.init()
        
        reloadBannerImage()
        reloadTitle()
        setupBinding()
        
        isFavorited.accept(value: favoritedResourcesCache.isFavorited(resourceId: resource.id))
        resourceDescription.accept(value: resource.attrCategory)
    }
    
    deinit {
        dataDownloader.attachmentsDownloaderStarted.removeObserver(self)
        dataDownloader.attachmentsDownloaderProgress.removeObserver(self)
        dataDownloader.attachmentDownloaded.removeObserver(self)
        dataDownloader.attachmentsDownloaderCompleted.removeObserver(self)
        languageSettingsService.primaryLanguage.removeObserver(self)
        languageSettingsService.parallelLanguage.removeObserver(self)
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
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadTitle()
            }
        }
        languageSettingsService.parallelLanguage.addObserver(self) { [weak self] (parallelLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadParallelLanguageName()
            }
        }
    }
    
    private func reloadBannerImage() {
            
        let image: UIImage? = dataDownloader.attachmentsFileCache.getAttachmentBanner(attachmentId: resource.attrBanner)
        bannerImage.accept(value: image)
    }
    
    private func reloadTitle() {
        
        let languageTranslationResult: FetchLanguageTranslationResult = fetchLanguageTranslationViewModel.getLanguageTranslation(
            resourceId: resource.id,
            languageId: languageSettingsService.primaryLanguage.value?.id ?? "",
            supportedFallbackTypes: [.englishLanguage]
        )
        
        if let translation = languageTranslationResult.translation {
            title.accept(value: translation.translatedName)
        }
        else {
            title.accept(value: resource.name)
        }
    }
    
    private func reloadParallelLanguageName() {

        let parallelLanguage: LanguageModel? = languageSettingsService.parallelLanguage.value
                
        parallelLanguageName.accept(value: getLanguageName(language: parallelLanguage))
    }
    
    private func getLanguageName(language: LanguageModelType?) -> String {
        
        if let language = language {
            
            if resource.supportsLanguage(languageId: language.id) {
                let nameAvailablePrefix: String = "✓ "
                let translatedName: String = language.translatedName(translateLanguageNameViewModel: translateLanguageNameViewModel)
                
                return nameAvailablePrefix + translatedName
            }
        }
        return ""
    }
}
