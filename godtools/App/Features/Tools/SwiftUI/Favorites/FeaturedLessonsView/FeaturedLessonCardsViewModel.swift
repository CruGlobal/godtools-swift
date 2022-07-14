//
//  FeaturedLessonCardsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol FeaturedLessonCardsViewModelDelegate: LessonCardDelegate {
    func lessonsAreLoading(_ isLoading: Bool)
}

class FeaturedLessonCardsViewModel: LessonCardProvider {
    
    // MARK: - Properties
    
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private weak var delegate: FeaturedLessonCardsViewModelDelegate?
    
    // MARK: - Published
    
    @Published var sectionTitle: String = ""
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, delegate: FeaturedLessonCardsViewModelDelegate?) {
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.delegate = delegate
        
        super.init()
        
        reloadLessonsFromCache()
        
        setup()
    }
    
    deinit {
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
        languageSettingsService.primaryLanguage.removeObserver(self)
    }
    
    // MARK: - Overrides
    
    override func cardViewModel(for lesson: ResourceModel) -> BaseLessonCardViewModel {
        return LessonCardViewModel(
            resource: lesson,
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            delegate: delegate
        )
    }
}

// MARK: - Private

extension FeaturedLessonCardsViewModel {
    
    private func setup() {
        setupTitle()
        setupBinding()
    }
    
    private func setupTitle() {
        let languageBundle = localizationServices.bundleLoader.bundleForPrimaryLanguageOrFallback(in: languageSettingsService)
        sectionTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "favorites.favoriteLessons.title")
    }
    
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.lessonsAreLoading(!cachedResourcesAvailable)
                if cachedResourcesAvailable {
                    self?.reloadLessonsFromCache()
                }
            }
        }
        
        dataDownloader.resourcesUpdatedFromRemoteDatabase.addObserver(self) { [weak self] (error: InitialDataDownloaderError?) in
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.lessonsAreLoading(false)
                if error == nil {
                    self?.reloadLessonsFromCache()
                }
            }
        }
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.setupTitle()
            }
        }
    }
    
    private func reloadLessonsFromCache() {
        lessons = dataDownloader.resourcesCache.getAllVisibleLessonsSorted(andFilteredBy: { $0.attrSpotlight })
    }
}
