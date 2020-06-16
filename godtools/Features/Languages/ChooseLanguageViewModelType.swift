//
//  ChooseLanguageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ChooseLanguageViewModelType {
    
    var navTitle: ObservableValue<String> { get }
    var deleteLanguageButtonTitle: String { get }
    var hidesDeleteLanguageButton: ObservableValue<Bool> { get }
    var languages: ObservableValue<[ChooseLanguageModel]> { get }
    var selectedLanguage: ObservableValue<ChooseLanguageModel?> { get }
    
    func pageViewed()
    func deleteLanguageTapped()
    func languageTapped(language: ChooseLanguageModel)
    func searchLanguageTextInputChanged(text: String)
}
