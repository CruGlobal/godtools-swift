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

class LessonCardViewModel: BaseLessonCardViewModel, ToolItemInitialDownloadProgress {
    
    // MARK: - Properties
    
    let resource: ResourceModel
    let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase
    private weak var delegate: LessonCardDelegate?

    var attachmentsDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    var translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    var downloadAttachmentsReceipt: DownloadAttachmentsReceipt?
    var downloadResourceTranslationsReceipt: DownloadTranslationsReceipt?
    
    // MARK: - Init
    
    init(resource: ResourceModel, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase, delegate: LessonCardDelegate?) {
        self.resource = resource
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.getLanguageAvailabilityStringUseCase = getLanguageAvailabilityStringUseCase
        self.delegate = delegate
        
        super.init()
        
        setup()
    }
    
    // MARK: - Deinit
    
    deinit {
        removeDataDownloaderObservers()
        languageSettingsService.primaryLanguage.removeObserver(self)
        attachmentsDownloadProgress.removeObserver(self)
        translationDownloadProgress.removeObserver(self)
    }
    
    // MARK: - Overrides
    
    override func lessonCardTapped() {
        delegate?.lessonCardTapped(resource: resource)
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
        let primaryLanguage = languageSettingsService.primaryLanguage.value
        
        if let primaryLanguage = primaryLanguage, let primaryTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguage.id) {
            
            titleValue = primaryTranslation.translatedName
        }
        else if let englishTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageCode: "en") {
            
            titleValue = englishTranslation.translatedName
        }
        else {
            
            titleValue = resource.resourceDescription
        }
        
        title = titleValue
        
        let languageAvailability = getLanguageAvailabilityStringUseCase.getLanguageAvailability(for: resource, language: primaryLanguage)
        translationAvailableText = languageAvailability.string
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
        
        attachmentsDownloadProgress.addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async {
                withAnimation {
                    self?.attachmentsDownloadProgressValue = progress
                }
            }
        }
        translationDownloadProgress.addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async {
                withAnimation {
                    self?.translationDownloadProgressValue = progress
                }
            }
        }
    }
}
