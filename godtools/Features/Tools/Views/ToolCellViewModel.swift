//
//  ToolCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolCellViewModel: NSObject, ToolCellViewModelType {
    
    private static let languageAvailableColor: UIColor = UIColor.hexColor(hexValue: 0x808284)
    private static let languageNotAvailableColor: UIColor = UIColor.hexColor(hexValue: 0xF40036)
    
    private let resource: ResourceModel
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let translateLanguageNameViewModel: TranslateLanguageNameViewModel
    
    let bannerImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let attachmentsDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let articlesDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let title: String
    let resourceDescription: String
    let primaryLanguageName: ObservableValue<String> = ObservableValue(value: "")
    let primaryLanguageColor: ObservableValue<UIColor> = ObservableValue(value: ToolCellViewModel.languageAvailableColor)
    let parallelLanguageName: ObservableValue = ObservableValue(value: "")
    let parallelLanguageColor: ObservableValue<UIColor> = ObservableValue(value: ToolCellViewModel.languageAvailableColor)
    let isFavorited: ObservableValue = ObservableValue(value: false)
    
    required init(resource: ResourceModel, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, translateLanguageNameViewModel: TranslateLanguageNameViewModel, favoritedResourcesService: FavoritedResourcesService) {
        
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.translateLanguageNameViewModel = translateLanguageNameViewModel
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
    
    private func reloadPrimaryLanguageName() {
        
        let primaryLanguage: LanguageModel? = languageSettingsService.primaryLanguage.value
        
        primaryLanguageName.accept(value: getLanguageName(language: primaryLanguage))
        primaryLanguageColor.accept(value: getLanguageColor(language: primaryLanguage))
    }
    
    private func reloadParallelLanguageName() {

        let parallelLanguage: LanguageModel? = languageSettingsService.parallelLanguage.value
                
        parallelLanguageName.accept(value: getLanguageName(language: parallelLanguage))
        parallelLanguageColor.accept(value: getLanguageColor(language: parallelLanguage))
    }
    
    private func getLanguageName(language: LanguageModelType?) -> String {
        
        if let language = language {
                        
            let nameAvailablePrefix: String = resourceSupportsLanguage(languageId: language.id) ? "✓ " : "x "
            let translatedName: String = translateLanguageNameViewModel.getTranslatedName(language: language, shouldFallbackToPrimaryLanguageLocale: false)
            
            return nameAvailablePrefix + translatedName
        }
        return ""
    }
    
    private func getLanguageColor(language: LanguageModelType?) -> UIColor {
        
        if let language = language {
            return resourceSupportsLanguage(languageId: language.id) ? ToolCellViewModel.languageAvailableColor : ToolCellViewModel.languageNotAvailableColor
        }
        else {
            return ToolCellViewModel.languageNotAvailableColor
        }
    }
    
    private func resourceSupportsLanguage(languageId: String) -> Bool {
        if !languageId.isEmpty {
            return resource.languageIds.contains(languageId)
        }
        return false
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
                self?.reloadPrimaryLanguageName()
            }
        }
        languageSettingsService.parallelLanguage.addObserver(self) { [weak self] (parallelLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadParallelLanguageName()
            }
        }
    }
}
