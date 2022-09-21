//
//  LessonCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI
import Combine

protocol LessonCardDelegate: AnyObject {
    func lessonCardTapped(lesson: LessonDomainModel)
}

class LessonCardViewModel: BaseLessonCardViewModel, ResourceItemInitialDownloadProgress {
    
    // MARK: - Properties
    
    let lesson: LessonDomainModel
    let dataDownloader: InitialDataDownloader
    
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    
    private weak var delegate: LessonCardDelegate?

    var attachmentsDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    var translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    var downloadAttachmentsReceipt: DownloadAttachmentsReceipt?
    var downloadResourceTranslationsReceipt: DownloadTranslationsReceipt?
    
    private var cancellables = Set<AnyCancellable>()
    
    var resourceId: String {
        return lesson.id
    }
    
    // MARK: - Init
    
    init(lesson: LessonDomainModel, dataDownloader: InitialDataDownloader, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, delegate: LessonCardDelegate?) {
        self.lesson = lesson
        self.dataDownloader = dataDownloader
        
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        
        self.delegate = delegate
        
        super.init()
        
        setup()
    }
    
    // MARK: - Deinit
    
    deinit {
        removeDataDownloaderObservers()
        attachmentsDownloadProgress.removeObserver(self)
        translationDownloadProgress.removeObserver(self)
    }
    
    // MARK: - Overrides
    
    override func lessonCardTapped() {
        delegate?.lessonCardTapped(lesson: lesson)
    }
}

// MARK: - Private

extension LessonCardViewModel {
    
    private func setup() {
        setupBinding()
        
        addDataDownloaderObservers()
    }
    
    private func reloadTitle(for primaryLanguage: LanguageDomainModel?) {
        guard let primaryLanguage = primaryLanguage else { return }

        let resourcesCache: ResourcesCache = dataDownloader.resourcesCache
             
        let titleValue: String
        
        if let primaryTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: lesson.id, languageId: primaryLanguage.id) {
            
            titleValue = primaryTranslation.translatedName
        }
        else if let englishTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: lesson.id, languageCode: "en") {
            
            titleValue = englishTranslation.translatedName
        }
        else {
            
            titleValue = lesson.description
        }
        
        title = titleValue
        
        let languageAvailability = getLanguageAvailabilityUseCase.getLanguageAvailability(for: lesson, language: primaryLanguage)
        translationAvailableText = languageAvailability.availabilityString
    }
    
    private func setupBinding() {
        
        getBannerImageUseCase.getBannerImagePublisher(for: lesson.bannerImageId)
            .receiveOnMain()
            .assign(to: \.bannerImage, on: self)
            .store(in: &cancellables)
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receiveOnMain()
            .sink { [weak self] primaryLanguage in
                self?.reloadTitle(for: primaryLanguage)
            }
            .store(in: &cancellables)
        
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
