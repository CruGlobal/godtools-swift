//
//  LanguagesListViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class LanguagesListViewModel: ObservableObject {
    
    @Published var languages: [ToolLanguageModel] = Array()
    
    let closeTappedClosure: (() -> Void)
    let languageTappedClosure: ((_ language: ToolLanguageModel) -> Void)
        
    required init(languages: [ToolLanguageModel], closeTappedClosure: @escaping (() -> Void), languageTappedClosure: @escaping ((_ language: ToolLanguageModel) -> Void)) {
        
        self.languages = languages
        self.closeTappedClosure = closeTappedClosure
        self.languageTappedClosure = languageTappedClosure
    }
    
    func getLanguagesListItemViewModel(language: ToolLanguageModel) -> LanguagesListItemViewModel {
        return LanguagesListItemViewModel(language: language)
    }
    
    func closeTapped() {
            
        closeTappedClosure()
    }
    
    func languageTapped(language: ToolLanguageModel) {
            
        languageTappedClosure(language)
    }
}
