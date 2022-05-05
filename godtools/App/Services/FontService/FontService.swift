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
    
    func getFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        
        guard let primaryLanguageCode: String = languageSettings.primaryLanguage.value?.code, !primaryLanguageCode.isEmpty else {
            
            return getDefaultFont(size: size, weight: weight)
        }
        
        let font: UIFont?
        
        if primaryLanguageCode == "am" {
            if weight == UIFont.Weight.semibold || weight == UIFont.Weight.bold {
                font = FontLibrary.notoSansEthiopicBold.uiFont(size: size)
            } else {
                font = FontLibrary.notoSansEthiopic.uiFont(size: size)
            }
        }
        else if primaryLanguageCode == "my" {
            if weight == UIFont.Weight.semibold || weight == UIFont.Weight.bold {
                font = FontLibrary.notoSansMyanmarBold.uiFont(size: size)
            } else {
                font = FontLibrary.notoSansMyanmar.uiFont(size: size)
            }
        }
        else {
            font = nil
        }
        
        return font ?? getDefaultFont(size: size, weight: weight)
    }
    
    private func getDefaultFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}
