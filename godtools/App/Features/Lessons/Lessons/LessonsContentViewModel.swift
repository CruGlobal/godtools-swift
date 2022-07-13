//
//  LessonsContentViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class LessonsContentViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    
    private(set) lazy var lessonsListViewModel: LessonsListViewModel = {
        return LessonsListViewModel(
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            delegate: self
        )
    }()
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices) {
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        
    }
    
}

// MARK: - LessonCardsViewModelDelegate

extension LessonsContentViewModel: LessonCardsViewModelDelegate {
    func lessonsAreLoading(_ isLoading: Bool) {
        // TODO
    }
    
    func lessonCardTapped(resource: ResourceModel) {
        // TODO
    }
}
