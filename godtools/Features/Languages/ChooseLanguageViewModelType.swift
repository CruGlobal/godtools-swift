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
    var languages: ObservableValue<[Language]> { get }
    var selectedLanguage: ObservableValue<Language?> { get }
    
    func pageViewed()
    func deleteLanguageTapped()
    func languageTapped(language: Language)
}
