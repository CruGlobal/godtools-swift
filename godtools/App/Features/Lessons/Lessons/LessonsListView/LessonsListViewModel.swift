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
    
    private weak var delegate: LessonsListViewModelDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published
    
    @Published var sectionTitle: String = ""
    @Published var subtitle: String = ""
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase, getLessonsUseCase: GetLessonsUseCase, delegate: LessonsListViewModelDelegate?) {
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityStringUseCase = getLanguageAvailabilityStringUseCase
        self.getLessonsUseCase = getLessonsUseCase
        
        self.delegate = delegate
        
        super.init()
                
        setup()
    }
    
    deinit {
        languageSettingsService.primaryLanguage.removeObserver(self)
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
    
    private func setup() {
        setupTitle()
        setupBinding()
    }
    
    private func setupTitle() {
        let languageBundle = localizationServices.bundleLoader.bundleForPrimaryLanguageOrFallback(in: languageSettingsService)
        sectionTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "lessons.pageTitle")
        subtitle = localizationServices.stringForBundle(bundle: languageBundle, key: "lessons.pageSubtitle")
    }
    
    private func setupBinding() {
        
        getLessonsUseCase.getLessonsPublisher()
            .receiveOnMain()
            .sink { lessons in
                
                self.delegate?.lessonsAreLoading(lessons.isEmpty)
                self.lessons = lessons
            }
            .store(in: &cancellables)
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.setupTitle()
            }
        }
    }
}

