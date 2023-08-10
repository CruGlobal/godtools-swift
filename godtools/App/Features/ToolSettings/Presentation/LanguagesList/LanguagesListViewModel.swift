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
    private let languageTappedClosure: ((_ language: LanguageDomainModel) -> Void)
    private let deleteTappedClosure: (() -> Void)?
    
    @Published var languages: [LanguageDomainModel] = Array()
        
    init(languages: [LanguageDomainModel], selectedLanguageId: String?, localizationServices: LocalizationServices, closeTappedClosure: @escaping (() -> Void), languageTappedClosure: @escaping ((_ language: LanguageDomainModel) -> Void), deleteTappedClosure: (() -> Void)?) {
        
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
    
    func getLanguagesListItemViewModel(language: LanguageDomainModel) -> BaseLanguagesListItemViewModel {
        return LanguagesListItemViewModel(language: language, selectedLanguageId: selectedLanguageId)
    }
}

// MARK: - Inputs

extension LanguagesListViewModel {
    
    func closeTapped() {
            
        closeTappedClosure()
    }
    
    func languageTapped(language: LanguageDomainModel) {
            
        languageTappedClosure(language)
    }
    
    func deleteTapped() {
        
        deleteTappedClosure?()
    }
}