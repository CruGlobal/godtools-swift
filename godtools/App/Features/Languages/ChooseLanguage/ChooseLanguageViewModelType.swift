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
    var closeKeyboardTitle: String { get }
    var hidesDeleteLanguageButton: ObservableValue<Bool> { get }
    var numberOfLanguages: ObservableValue<Int> { get }
    var selectedLanguageIndex: ObservableValue<Int?> { get }
    
    func pageViewed()
    func deleteLanguageTapped()
    func languageTapped(index: Int)
    func searchLanguageTextInputChanged(text: String)
    func willDisplayLanguage(index: Int) -> ChooseLanguageCellViewModel
}
