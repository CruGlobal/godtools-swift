//
//  LanguagesListViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class LanguagesListViewModel: BaseLanguagesListViewModel {
    
    private let selectedLanguageId: String?
    private let localizationServices: LocalizationServices
    private let closeTappedClosure: (() -> Void)
    private let languageTappedClosure: ((_ language: ToolLanguageModel) -> Void)
    private let deleteTappedClosure: (() -> Void)?
        
    required init(languages: [ToolLanguageModel], selectedLanguageId: String?, localizationServices: LocalizationServices, closeTappedClosure: @escaping (() -> Void), languageTappedClosure: @escaping ((_ language: ToolLanguageModel) -> Void), deleteTappedClosure: (() -> Void)?) {
        
        self.selectedLanguageId = selectedLanguageId
        self.localizationServices = localizationServices
        self.closeTappedClosure = closeTappedClosure
        self.languageTappedClosure = languageTappedClosure
        self.deleteTappedClosure = deleteTappedClosure
        
        super.init()
        
        self.languages = languages
    }
    
    private var hidesDeleteOption: Bool {
        return deleteTappedClosure == nil
    }
    
    override func getDeleteLanguageListItemViewModel() -> DeleteLanguageListItemViewModel? {
        guard !hidesDeleteOption else {
            return nil
        }
        
        return DeleteLanguageListItemViewModel(localizationServices: localizationServices)
    }
    
    override func getLanguagesListItemViewModel(language: ToolLanguageModel) -> BaseLanguagesListItemViewModel {
        return LanguagesListItemViewModel(language: language, selectedLanguageId: selectedLanguageId)
    }
    
    override func closeTapped() {
            
        closeTappedClosure()
    }
    
    override func languageTapped(language: ToolLanguageModel) {
            
        languageTappedClosure(language)
    }
    
    override func deleteTapped() {
        
        deleteTappedClosure?()
    }
}
