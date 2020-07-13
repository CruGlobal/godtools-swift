//
//  ChooseLanguageCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ChooseLanguageCellViewModel: ChooseLanguageCellViewModelType {
    
    let languageName: String
    let languageIsDownloaded: Bool
    let hidesSelected: Bool
    let hidesSeparator: Bool
    
    required init(language: LanguageModel, translateLanguageNameViewModel: TranslateLanguageNameViewModel, downloadedLanguagesCache: DownloadedLanguagesCache, hidesDownloadButton: Bool, hidesSelected: Bool) {
        
        self.languageName = language.translatedName(translateLanguageNameViewModel: translateLanguageNameViewModel)
        self.languageIsDownloaded = downloadedLanguagesCache.isDownloaded(languageId: language.id)
        self.hidesSelected = hidesSelected
        self.hidesSeparator = !hidesSelected
    }
}
