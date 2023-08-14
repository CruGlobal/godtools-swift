//
//  FeaturedLessonCardsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class FeaturedLessonCardsViewModel: ObservableObject {
        
    private let dataDownloader: InitialDataDownloader
    private let localizationServices: LocalizationServices
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let translationsRepository: TranslationsRepository
    
    private var cancellables = Set<AnyCancellable>()
            
    @Published var sectionTitle: String = ""
    @Published var lessons: [LessonDomainModel] = []
        
    init(dataDownloader: InitialDataDownloader, localizationServices: LocalizationServices, getBannerImageUseCase: GetBannerImageUseCase, getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, translationsRepository: TranslationsRepository) {
        
        self.dataDownloader = dataDownloader
        self.localizationServices = localizationServices
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getFeaturedLessonsUseCase = getFeaturedLessonsUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.translationsRepository = translationsRepository
                                
        getFeaturedLessonsUseCase.getFeaturedLessonsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] featuredLessons in
                
                self?.lessons = featuredLessons
            }
            .store(in: &cancellables)
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] primaryLanguage in
                
                self?.setupTitle(with: primaryLanguage)
            }
            .store(in: &cancellables)
    }
    
    private func setupTitle(with language: LanguageDomainModel?) {
        
        sectionTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: language?.localeIdentifier, key: "favorites.favoriteLessons.title")
    }
}

// MARK: - Inputs

extension FeaturedLessonCardsViewModel {
    
    func cardViewModel(for lesson: LessonDomainModel) -> LessonCardViewModel {
        
        return LessonCardViewModel(
            lesson: lesson,
            dataDownloader: dataDownloader,
            translationsRepository: translationsRepository,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase
        )
    }
}
