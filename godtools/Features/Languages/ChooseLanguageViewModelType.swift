//
//  ChooseLanguageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ChooseLanguageViewModelType {
    
    var translateLanguageNameViewModel: TranslateLanguageNameViewModel { get }
    var downloadedLanguagesCache: DownloadedLanguagesCache { get }
    var navTitle: ObservableValue<String> { get }
    var deleteLanguageButtonTitle: String { get }
    var closeKeyboardTitle: String { get }
    var hidesDeleteLanguageButton: ObservableValue<Bool> { get }
    var languages: ObservableValue<[LanguageModel]> { get }
    var selectedLanguage: ObservableValue<LanguageModel?> { get }
    
    func pageViewed()
    func deleteLanguageTapped()
    func languageTapped(language: LanguageModel)
    func searchLanguageTextInputChanged(text: String)
}
