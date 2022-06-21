//
//  SetupParallelLanguageViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 11/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class SetupParallelLanguageViewModel: NSObject, SetupParallelLanguageViewModelType {
    
    private weak var flowDelegate: FlowDelegate?
    
    private let localizationServices: LocalizationServices
    private let languageSettingsService: LanguageSettingsService
    private let getTranslatedLanguageUseCase: GetTranslatedLanguageUseCase
    
    let animatedViewModel: AnimatedViewModel
    let promptText: String
    let yesButtonText: String
    let noButtonText: String
    let selectButtonText: String
    let getStartedButtonText: String
    let selectLanguageButtonText: ObservableValue<String>
    let yesNoButtonsHidden: ObservableValue<Bool>
    let getStartedButtonHidden: ObservableValue<Bool>
    
    required init (flowDelegate: FlowDelegate, localizationServices: LocalizationServices, languageSettingsService: LanguageSettingsService, getTranslatedLanguageUseCase: GetTranslatedLanguageUseCase, setupParallelLanguageAvailability: SetupParallelLanguageAvailabilityType) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.languageSettingsService = languageSettingsService
        self.getTranslatedLanguageUseCase = getTranslatedLanguageUseCase
        
        animatedViewModel = AnimatedViewModel(
            animationDataResource: .mainBundleJsonFile(filename: "onboarding_parallel_language"),
            autoPlay: true,
            loop: true
        )
        
        promptText = localizationServices.stringForMainBundle(key: "parellelLanguage.prompt")
        yesButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.yesButton.title")
        noButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.noButton.title")
        selectButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.selectButton.title")
        getStartedButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.getStartedButton.title")
        selectLanguageButtonText = ObservableValue(value: "")
        yesNoButtonsHidden = ObservableValue(value: false)
        getStartedButtonHidden = ObservableValue(value: true)
        
        super.init()
        
        setupParallelLanguageAvailability.markSetupParallelLanguageViewed()
        
        reloadData()
        
        setupBinding()
    }
    
    deinit {
        
        print("x deinit: \(type(of: self))")
        
        languageSettingsService.parallelLanguage.removeObserver(self)
    }
    
    private func reloadData() {
                
        if let parallelLanguage = languageSettingsService.parallelLanguage.value {
            
            let buttonText: String = getTranslatedLanguageUseCase.getTranslatedLanguage(language: parallelLanguage).name
            
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
    
    func languageSelectorTapped() {
        
        flowDelegate?.navigate(step: .languageSelectorTappedFromSetupParallelLanguage)
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
