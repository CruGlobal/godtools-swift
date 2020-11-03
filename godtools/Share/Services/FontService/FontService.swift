//
//  FontService.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class FontService {
    
    private let languageSettings: LanguageSettingsService
    
    required init(languageSettings: LanguageSettingsService) {
        
        self.languageSettings = languageSettings
    }
    
    func getFont(size: CGFloat) -> UIFont {
        
        return getFont(size: size, weight: .regular)
    }
    
    func getFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        
        let font: UIFont?
        
        if languageSettings.primaryLanguage.value?.code == "am" {
            if weight == UIFont.Weight.semibold || weight == UIFont.Weight.bold {
                font = FontLibrary.notoSansEthiopicBold.font(size: size)
            } else {
                font = FontLibrary.notoSansEthiopic.font(size: size)
            }
        }
        else {
            font = nil
        }
        
        return font ?? UIFont.systemFont(ofSize: size, weight: UIFont.Weight.regular)
    }
}
