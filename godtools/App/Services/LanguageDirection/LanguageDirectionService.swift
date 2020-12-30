//
//  LanguageDirectionService.swift
//  godtools
//
//  Created by Levi Eggert on 11/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class LanguageDirectionService: NSObject {
    
    private let languageSettings: LanguageSettingsService
    
    let primaryLanguageDirection: ObservableValue<LanguageDirection> = ObservableValue(value: .leftToRight)
    
    required init(languageSettings: LanguageSettingsService) {
        
        self.languageSettings = languageSettings
        
        super.init()
        
        setupBinding()
    }
    
    deinit {
        
        languageSettings.primaryLanguage.removeObserver(self)
    }
    
    var systemLanguageDirection: LanguageDirection {
        
        let systemLayoutDirection: UIUserInterfaceLayoutDirection = UIApplication.shared.userInterfaceLayoutDirection
        
        if systemLayoutDirection == .rightToLeft {
            return .rightToLeft
        }
        
        return .leftToRight
    }
    
    private func setupBinding() {
        
        languageSettings.primaryLanguage.addObserver(self) { [weak self] (language: LanguageModel?) in
            
            guard let primaryLanguage = language else {
                self?.primaryLanguageDirection.accept(value: .leftToRight)
                return
            }
            
            self?.primaryLanguageDirection.accept(value: primaryLanguage.languageDirection)
        }
    }
}
