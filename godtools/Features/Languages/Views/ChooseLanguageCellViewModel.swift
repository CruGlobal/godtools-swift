//
//  ChooseLanguageCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ChooseLanguageCellViewModel: ChooseLanguageCellViewModelType {
    
    let languageText: ObservableValue<String> = ObservableValue(value: "")
    let hidesDownloadButton: ObservableValue<Bool> = ObservableValue(value: false)
    let hidesSelected: Bool
    
    required init(language: Language, selectedLanguage: Language?) {
        
        languageText.accept(value: language.localizedName())
        hidesDownloadButton.accept(value: language.shouldDownload)
        hidesSelected = language.remoteId != selectedLanguage?.remoteId
    }
}
