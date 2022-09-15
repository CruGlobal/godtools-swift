//
//  LessonsListViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

protocol LessonsListViewModelDelegate: LessonCardDelegate {
    func lessonsAreLoading(_ isLoading: Bool)
}

class LessonsListViewModel: LessonCardProvider {
    
    // MARK: - Properties
    
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase
    private let getLessonsUseCase: GetLessonsUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    
    private weak var delegate: LessonsListViewModelDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published
    
    @Published var sectionTitle: String = ""
    @Published var subtitle: String = ""
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase, getLessonsUseCase: GetLessonsUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, delegate: LessonsListViewModelDelegate?) {
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityStringUseCase = getLanguageAvailabilityStringUseCase
        self.getLessonsUseCase = getLessonsUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        
        self.delegate = delegate
        
        super.init()
                
        setupBinding()
    }
    
    // MARK: - Overrides
    
    override func cardViewModel(for lesson: LessonDomainModel) -> BaseLessonCardViewModel {
        return LessonCardViewModel(
            lesson: lesson,
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase,
            delegate: delegate
        )
    }
}

// MARK: - Private

extension LessonsListViewModel {
    
    private func setupBinding() {
        
        getLessonsUseCase.getLessonsPublisher()
            .receiveOnMain()
            .sink { lessons in
                
                self.delegate?.lessonsAreLoading(lessons.isEmpty)
                self.lessons = lessons
            }
            .store(in: &cancellables)
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receiveOnMain()
            .sink { primaryLanguage in
                self.setupTitle(with: primaryLanguage)
            }
            .store(in: &cancellables)
    }
    
    private func setupTitle(with language: LanguageDomainModel?) {
        guard let language = language,
              let languageBundle = localizationServices.bundleLoader.bundleForResource(resourceName: language.localeIdentifier)
        else { return }
        
        sectionTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "lessons.pageTitle")
        subtitle = localizationServices.stringForBundle(bundle: languageBundle, key: "lessons.pageSubtitle")
    }
}

