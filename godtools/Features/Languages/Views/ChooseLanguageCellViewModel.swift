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
    let hidesDownloadButton: Bool
    let hidesSelected: Bool
    let hidesSeparator: Bool
    
    required init(language: ChooseLanguageModel, hidesDownloadButton: Bool, hidesSelected: Bool) {
        
        self.languageName = language.languageName
        self.hidesDownloadButton = hidesDownloadButton
        self.hidesSelected = hidesSelected
        self.hidesSeparator = !hidesSelected
    }
}
