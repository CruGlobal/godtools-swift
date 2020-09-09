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
    
    required init(languageViewModel: LanguageViewModel, languageIsDownloaded: Bool, hidesSelected: Bool) {
                
        self.languageName = languageViewModel.translatedLanguageName
        self.languageIsDownloaded = languageIsDownloaded
        self.hidesSelected = hidesSelected
        self.hidesSeparator = !hidesSelected
    }
}
