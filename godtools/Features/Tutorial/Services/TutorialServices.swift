//
//  TutorialServices.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TutorialServices: TutorialServicesType {
    
    private static let keyOpenTutorialCalloutDisabled: String = "keyOpenTutorialCalloutDisabled"
    
    private let languagePreferences: LanguagePreferencesType
    
    init(languagePreferences: LanguagePreferencesType) {
        self.languagePreferences = languagePreferences
    }
    
    var tutorialIsAvailable: Bool {
        return languagePreferences.isEnglish
    }
    
    var openTutorialCalloutIsAvailable: Bool {
        return tutorialIsAvailable && !openTutorialCalloutDisabled
    }
    
    private var openTutorialCalloutDisabled: Bool {
        if let disabled = UserDefaults.getData(key: TutorialServices.keyOpenTutorialCalloutDisabled) as? Bool {
            return disabled
        }
        return false
    }
    
    func disableOpenTutorialCallout() {
        UserDefaults.saveData(
            data: true,
            key: TutorialServices.keyOpenTutorialCalloutDisabled
        )
    }
}
