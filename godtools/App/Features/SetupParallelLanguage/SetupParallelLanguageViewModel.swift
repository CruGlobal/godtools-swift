//
//  SetupParallelLanguageViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 11/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class SetupParallelLanguageViewModel: NSObject, SetupParallelLanguageViewModelType {
    
    private let localizationServices: LocalizationServices
    private let languageSettingsService: LanguageSettingsService

    private weak var flowDelegate: FlowDelegate?

    let animatedViewModel: AnimatedViewModel
    let promptText: String
    let selectLanguageButtonText: ObservableValue<String> = ObservableValue(value: "")
    let yesButtonText: String
    let noButtonText: String
    let selectButtonText: String
    let getStartedButtonText: String
    let yesNoButtonsHidden: ObservableValue<Bool> = ObservableValue(value: false)
    let getStartedButtonHidden: ObservableValue<Bool> = ObservableValue(value: true)
    
    required init (flowDelegate: FlowDelegate, localizationServices: LocalizationServices, languageSettingsService: LanguageSettingsService) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.languageSettingsService = languageSettingsService
        
        animatedViewModel = AnimatedViewModel(
            animationDataResource: .mainBundleJsonFile(filename: "onboarding_two_dudes"),
            autoPlay: true,
            loop: true
        )
        
        promptText = localizationServices.stringForMainBundle(key: "parellelLanguage.prompt")
        yesButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.yesButton.title")
        noButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.noButton.title")
        selectButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.selectButton.title")
        getStartedButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.getStartedButton.title")
        
        super.init()
        
        
        reloadData()
        
        setupBinding()
    }
    
    
    private func reloadData() {
                
        if let parallelLanguage = languageSettingsService.parallelLanguage.value {
            
            let buttonText = LanguageViewModel(language: parallelLanguage, localizationServices: localizationServices).translatedLanguageName
            
            selectLanguageButtonText.accept(value: buttonText)
            yesNoButtonsHidden.accept(value: true)
            getStartedButtonHidden.accept(value: false)
        }
        else {
            let buttonText = localizationServices.stringForMainBundle(key: "parallelLanguage.selectLanguageButton.title")
            
            selectLanguageButtonText.accept(value: buttonText)
            yesNoButtonsHidden.accept(value: false)
            getStartedButtonHidden.accept(value: true)
        }
    }
    
    private func setupBinding() {
        
        languageSettingsService.parallelLanguage.addObserver(self) { [weak self] (parallelLanguage: LanguageModel?) in
            
            DispatchQueue.main.async { [weak self] in
                
                self?.reloadData()
            }
        }
    }
    
    func selectLanguageTapped() {
        
        flowDelegate?.navigate(step: .selectLanguageTappedFromSetupParallelLanguage)
    }
    
    func closeButtonTapped() {
        
        flowDelegate?.navigate(step: .closeTappedFromSetupParallelLanguage)
    }
    
    func yesButtonTapped() {
        
        flowDelegate?.navigate(step: .yesTappedFromSetupParallelLanguage)

    }
    
    func noButtonTapped() {
        
        flowDelegate?.navigate(step: .noThanksTappedFromSetupParallelLanguage)
    }
    
    func getStartedButtonTapped() {
        
        flowDelegate?.navigate(step: .getStartedTappedFromSetupParallelLanguage)
    }
}
