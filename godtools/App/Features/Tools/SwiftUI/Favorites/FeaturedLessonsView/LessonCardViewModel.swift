//
//  LessonCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

protocol LessonCardDelegate: AnyObject {
    func lessonCardTapped(resource: ResourceModel)
}

class LessonCardViewModel: NSObject, ObservableObject, ToolItemInitialDownloadProgress {
    
    // MARK: - Properties
    
    let resource: ResourceModel
    let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService

    var attachmentsDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    var translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    var downloadAttachmentsReceipt: DownloadAttachmentsReceipt?
    var downloadResourceTranslationsReceipt: DownloadTranslationsReceipt?
    
    // MARK: - Published
    
    @Published var bannerImage: Image?
    @Published var title: String = ""
    
    // MARK: - Init
    
    init(resource: ResourceModel, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService) {
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        
        super.init()
        
        setup()
    }
    
    // MARK: - Deinit
    
    deinit {
        removeDataDownloaderObservers()
        languageSettingsService.primaryLanguage.removeObserver(self)
    }
    
    // MARK: - ToolItemInitialDownloadProgress
    
    func didDownloadAttachments() {
        reloadBannerImage()
    }
}

// MARK: - Private

extension LessonCardViewModel {
    private func setup() {
        setupPublishedProperties()
        setupBinding()
        
        addDataDownloaderObservers()
    }
    
    private func setupPublishedProperties() {
        reloadTitle()
        reloadBannerImage()
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
        
        title = titleValue
    }
    
    private func reloadBannerImage() {
        
        if let cachedImage = dataDownloader.attachmentsFileCache.getAttachmentBanner(attachmentId: resource.attrBanner) {
            
            bannerImage = Image(uiImage: cachedImage)
            
        } else {
            
            bannerImage = nil
        }

    }
    
    private func setupBinding() {
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            self?.reloadTitle()
        }
    }
}
