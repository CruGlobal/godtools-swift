//
//  LessonListItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonListItemViewModel: NSObject, LessonListItemViewModelType {
    
    private let languageSettingsService: LanguageSettingsService
    
    let resource: ResourceModel
    let dataDownloader: InitialDataDownloader
    let title: ObservableValue<String> = ObservableValue(value: "")
    let bannerImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let attachmentsDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    
    var downloadAttachmentsReceipt: DownloadAttachmentsReceipt?
    var downloadResourceTranslationsReceipt: DownloadTranslationsReceipt?
    
    required init(resource: ResourceModel, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService) {
        
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        
        super.init()
        
        reloadTitle()
        
        reloadBannerImage()
        
        addDataDownloaderObservers()
        
        setupBinding()
    }
    
    deinit {
        removeDataDownloaderObservers()
        languageSettingsService.primaryLanguage.removeObserver(self)
    }
    
    private func setupBinding() {
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            self?.reloadTitle()
        }
    }
    
    private func reloadTitle() {
        
        let resourcesCache: ResourcesCache = dataDownloader.resourcesCache
             
        let titleValue: String
        
        if let primaryLanguage = languageSettingsService.primaryLanguage.value, let primaryTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguage.id) {
            
            titleValue = primaryTranslation.translatedName
        }
        else if let englishTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageCode: "en") {
            
            titleValue = englishTranslation.translatedName
        }
        else {
            
            titleValue = resource.resourceDescription
        }
        
        title.accept(value: titleValue)
    }
    
    private func reloadBannerImage() {
            
        let image: UIImage?
        
        if let cachedImage = dataDownloader.attachmentsFileCache.getAttachmentBanner(attachmentId: resource.attrBanner) {
            image = cachedImage
        }
        else {
            image = nil
        }
        
        bannerImage.accept(value: image)
    }
    
    func didDownloadAttachments() {
        reloadBannerImage()
    }
}
