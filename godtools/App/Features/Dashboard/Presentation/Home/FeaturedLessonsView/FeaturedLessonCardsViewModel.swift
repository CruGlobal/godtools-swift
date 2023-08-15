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
        
    private let localizationServices: LocalizationServices
    private let getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let attachmentsRepository: AttachmentsRepository
    
    private var cancellables = Set<AnyCancellable>()
            
    @Published var sectionTitle: String = ""
    @Published var lessons: [LessonDomainModel] = []
        
    init(localizationServices: LocalizationServices, getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, attachmentsRepository: AttachmentsRepository) {
        
        self.localizationServices = localizationServices
        self.getFeaturedLessonsUseCase = getFeaturedLessonsUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.attachmentsRepository = attachmentsRepository
                                
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
            attachmentsRepository: attachmentsRepository
        )
    }
}
