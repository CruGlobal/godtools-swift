//
//  SetupParallelLanguageViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 11/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import Combine

class SetupParallelLanguageViewModel: SetupParallelLanguageViewModelType {
    
    private weak var flowDelegate: FlowDelegate?
    
    private let localizationServices: LocalizationServices
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    let animatedViewModel: AnimatedViewModel
    let promptText: String
    let yesButtonText: String
    let noButtonText: String
    let selectButtonText: String
    let getStartedButtonText: String
    let selectLanguageButtonText: ObservableValue<String>
    let yesNoButtonsHidden: ObservableValue<Bool>
    let getStartedButtonHidden: ObservableValue<Bool>
    
    required init (flowDelegate: FlowDelegate, localizationServices: LocalizationServices, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, setupParallelLanguageAvailability: SetupParallelLanguageAvailabilityType) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        
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
                
        setupParallelLanguageAvailability.markSetupParallelLanguageViewed()
        
        getSettingsParallelLanguageUseCase.getParallelLanguagePublisher()
            .receiveOnMain()
            .sink { [weak self] (parallelLanguage: LanguageDomainModel?) in
                
                let buttonText: String
                let yesNoButtonHidden: Bool
                let getStartedButtonHidden: Bool
                
                if let parallelLanguage = parallelLanguage {
                    
                    buttonText = parallelLanguage.translatedName
                    yesNoButtonHidden = true
                    getStartedButtonHidden = false
                }
                else {
                    
                    buttonText = localizationServices.stringForMainBundle(key: "parallelLanguage.selectLanguageButton.title")
                    yesNoButtonHidden = false
                    getStartedButtonHidden = true
                }
                
                self?.selectLanguageButtonText.accept(value: buttonText)
                self?.yesNoButtonsHidden.accept(value: yesNoButtonHidden)
                self?.getStartedButtonHidden.accept(value: getStartedButtonHidden)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
