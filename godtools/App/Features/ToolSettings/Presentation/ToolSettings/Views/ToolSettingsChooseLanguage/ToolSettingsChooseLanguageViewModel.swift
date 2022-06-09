//
//  ToolSettingsChooseLanguageViewModel.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import Foundation
import Combine

class ToolSettingsChooseLanguageViewModel: BaseToolSettingsChooseLanguageViewModel {
    
    private let localizationServices: LocalizationServices
    private let primaryLanguageSubject: CurrentValueSubject<LanguageModel, Never>
    private let parallelLanguageSubject: CurrentValueSubject<LanguageModel?, Never>
    
    private var primaryLanguageCancellable: AnyCancellable?
    private var parallelLanguageCancellable: AnyCancellable?
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, primaryLanguageSubject: CurrentValueSubject<LanguageModel, Never>, parallelLanguageSubject: CurrentValueSubject<LanguageModel?, Never>) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.primaryLanguageSubject = primaryLanguageSubject
        self.parallelLanguageSubject = parallelLanguageSubject
        
        super.init()
        
        title = localizationServices.stringForMainBundle(key: "toolSettings.chooseLanguage.title")
        
        primaryLanguageCancellable = primaryLanguageSubject.sink(receiveValue: { [weak self] (language: LanguageModel) in
            
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.primaryLanguageTitle = weakSelf.getTranslatedLanguageName(language: language)
        })
        
        parallelLanguageCancellable = parallelLanguageSubject.sink(receiveValue: { [weak self] (language: LanguageModel?) in
            
            guard let weakSelf = self else {
                return
            }
            
            if let language = language {
                weakSelf.parallelLanguageTitle = weakSelf.getTranslatedLanguageName(language: language)
            }
            else {
                weakSelf.parallelLanguageTitle = weakSelf.localizationServices.stringForMainBundle(key: "toolSettings.chooseLanguage.noParallelLanguageTitle")
            }
        })
    }
    
    private func getTranslatedLanguageName(language: LanguageModel) -> String {
        return LanguageViewModel(language: language, localizationServices: localizationServices).translatedLanguageName
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
