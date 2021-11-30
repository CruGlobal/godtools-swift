//
//  SetupParallelLanguageViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 11/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class SetupParallelLanguageViewModel: SetupParallelLanguageViewModelType {
    
    let animatedViewModel: AnimatedViewModel
    let promptText: String
    let languagePickerLabelText: String
    let yesButtonText: String
    let noButtonText: String
    let selectButtonText: String
    let getStartedButtonText: String
    
    private weak var flowDelegate: FlowDelegate?
    
    required init (flowDelegate: FlowDelegate, localizationServices: LocalizationServices) {
        
        animatedViewModel = AnimatedViewModel(
            animationDataResource: .mainBundleJsonFile(filename: "onboarding_two_dudes"),
            autoPlay: true,
            loop: true
        )
        
        promptText = localizationServices.stringForMainBundle(key: "parellelLanguage.prompt")
        languagePickerLabelText = localizationServices.stringForMainBundle(key: "parallelLanguage.languagePicker.title")
        yesButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.yesButton.title")
        noButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.noButton.title")
        selectButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.selectButton.title")
        getStartedButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.getStartedButton.title")
        
        self.flowDelegate = flowDelegate
    }
    
    func closeButtonTapped() {
        flowDelegate?.navigate(step: .closeTappedFromSetupParallelLanguage)
    }
    
    func yesButtonTapped() {
        
    }
    
    func noButtonTapped() {
        
    }
    
    func languageSelected(index: Int) {
        
    }
    
    func getStartedButtonTapped() {
        
    }
}
