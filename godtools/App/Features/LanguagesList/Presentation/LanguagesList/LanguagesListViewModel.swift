//
//  LanguagesListViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class LanguagesListViewModel: ObservableObject {
    
    private let selectedLanguageId: String?
    private let closeTappedClosure: (() -> Void)
    private let languageTappedClosure: ((_ language: ToolLanguageModel) -> Void)
    private let deleteTappedClosure: (() -> Void)?
    
    @Published var languages: [ToolLanguageModel] = Array()
    @Published var hidesDeleteOption: Bool = true
        
    required init(languages: [ToolLanguageModel], selectedLanguageId: String?, closeTappedClosure: @escaping (() -> Void), languageTappedClosure: @escaping ((_ language: ToolLanguageModel) -> Void), deleteTappedClosure: (() -> Void)?) {
        
        self.languages = languages
        self.selectedLanguageId = selectedLanguageId
        self.closeTappedClosure = closeTappedClosure
        self.languageTappedClosure = languageTappedClosure
        self.deleteTappedClosure = deleteTappedClosure        
        self.hidesDeleteOption = deleteTappedClosure == nil
    }
    
    func getLanguagesListItemViewModel(language: ToolLanguageModel) -> BaseLanguagesListItemViewModel {
        return LanguagesListItemViewModel(language: language, selectedLanguageId: selectedLanguageId)
    }
    
    func closeTapped() {
            
        closeTappedClosure()
    }
    
    func languageTapped(language: ToolLanguageModel) {
            
        languageTappedClosure(language)
    }
    
    func deleteTapped() {
        
        deleteTappedClosure?()
    }
}
