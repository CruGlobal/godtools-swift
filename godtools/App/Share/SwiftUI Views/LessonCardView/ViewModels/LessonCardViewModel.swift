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

class LessonCardViewModel: BaseLessonCardViewModel {
        
    private let translationsRepository: TranslationsRepository
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    private weak var delegate: LessonCardDelegate?
    
    let lesson: LessonDomainModel
    let dataDownloader: InitialDataDownloader
    
    init(lesson: LessonDomainModel, dataDownloader: InitialDataDownloader, translationsRepository: TranslationsRepository, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, delegate: LessonCardDelegate?) {
        self.lesson = lesson
        self.dataDownloader = dataDownloader
        
        self.translationsRepository = translationsRepository
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        
        self.delegate = delegate
        
        super.init()
        
        setup()
    }
    
    override func lessonCardTapped() {
        delegate?.lessonCardTapped(lesson: lesson)
    }
}

extension LessonCardViewModel {
    
    private func setup() {
        setupBinding()
    }
    
    private func reloadTitle(for primaryLanguage: LanguageDomainModel?) {
             
        let titleValue: String
        
        if let primaryLanguage = primaryLanguage, let primaryTranslation = translationsRepository.getLatestTranslation(resourceId: lesson.id, languageId: primaryLanguage.id) {
            
            titleValue = primaryTranslation.translatedName
        }
        else if let englishTranslation = translationsRepository.getLatestTranslation(resourceId: lesson.id, languageCode: LanguageCodes.english) {
            
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
            .receive(on: DispatchQueue.main)
            .assign(to: \.bannerImage, on: self)
            .store(in: &cancellables)
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] primaryLanguage in
                self?.reloadTitle(for: primaryLanguage)
            }
            .store(in: &cancellables)
    }
}
