//
//  ToolSettingsChooseLanguageViewModel.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import Foundation

class ToolSettingsChooseLanguageViewModel: BaseToolSettingsChooseLanguageViewModel {
    
    private let localizationServices: LocalizationServices
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        
        super.init()
                
        primaryLanguageTitle = LanguageViewModel(language: primaryLanguage, localizationServices: localizationServices).translatedLanguageName
        
        if let parallelLanguage = parallelLanguage {
            parallelLanguageTitle = LanguageViewModel(language: parallelLanguage, localizationServices: localizationServices).translatedLanguageName
        }
        else {
            parallelLanguageTitle = "Parallel"
        }
    }
    
    override func primaryLanguageTapped() {
        
        flowDelegate?.navigate(step: .primaryLanguageTappedFromToolSettings)
    }
    
    override func parallelLanguageTapped() {
        
        flowDelegate?.navigate(step: .parallelLanguageTappedFromToolSettings)
    }
    
    override func swapLanguageTapped() {
        
        flowDelegate?.navigate(step: .swapLanguagesTappedFromToolSettings)
    }
}
