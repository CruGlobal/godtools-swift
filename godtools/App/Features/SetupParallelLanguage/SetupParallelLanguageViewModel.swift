//
//  SetupParallelLanguageViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 11/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class SetupParallelLanguageViewModel: SetupParallelLanguageViewModelType {
    
    let animationViewModel: AnimatedViewModel
    let bodyText: String
    let languagePickerLabelText: String
    let yesButtonText: String
    let noButtonText: String
    let selectButtonText: String
    let getStartedButtonText: String
    
    required init (flowDelegate: FlowDelegate, localizationServices: LocalizationServices) {
        
        animationViewModel = AnimatedViewModel(
            animationDataResource: .mainBundleJsonFile(filename: "onboarding_two_dudes"),
            autoPlay: true,
            loop: true
        )
        
        bodyText = localizationServices.stringForMainBundle(key: "parellelLanguage.prompt")
        languagePickerLabelText = localizationServices.stringForMainBundle(key: "parallelLanguage.languagePicker.title")
        yesButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.yesButton.title")
        noButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.noButton.title")
        selectButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.selectButton.title")
        getStartedButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.getStartedButton.title")
    }
    
    func handleYesTapped() {
        
    }
    
    func handleNoTapped() {
        
    }
    
    func handleLanguageSelected(index: Int) {
        
    }
    
    func handleGetStartedTapped() {
        
    }
}
