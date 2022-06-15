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
    private let localizationServices: LocalizationServices
    private let closeTappedClosure: (() -> Void)
    private let languageTappedClosure: ((_ language: ToolLanguageModel) -> Void)
    private let deleteTappedClosure: (() -> Void)?
    
    @Published var languages: [ToolLanguageModel] = Array()
        
    required init(languages: [ToolLanguageModel], selectedLanguageId: String?, localizationServices: LocalizationServices, closeTappedClosure: @escaping (() -> Void), languageTappedClosure: @escaping ((_ language: ToolLanguageModel) -> Void), deleteTappedClosure: (() -> Void)?) {
        
        self.selectedLanguageId = selectedLanguageId
        self.localizationServices = localizationServices
        self.closeTappedClosure = closeTappedClosure
        self.languageTappedClosure = languageTappedClosure
        self.deleteTappedClosure = deleteTappedClosure
                
        self.languages = languages
    }
    
    private var hidesDeleteOption: Bool {
        return deleteTappedClosure == nil
    }
    
    func getDeleteLanguageListItemViewModel() -> DeleteLanguageListItemViewModel? {
        guard !hidesDeleteOption else {
            return nil
        }
        
        return DeleteLanguageListItemViewModel(localizationServices: localizationServices)
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
