//
//  ToolNavBarViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolNavBarViewModel {
    
    let navTitle: String
    let navBarColor: UIColor
    let navBarControlColor: UIColor
    let hidesChooseLanguageControl: Bool
    let chooseLanguageControlPrimaryLanguageTitle: String
    let chooseLanguageControlParallelLanguageTitle: String
    
    required init(manifestAttributes: MobileContentManifestAttributesType, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, localizationServices: LocalizationServices) {
        
        navTitle = "GodTools"
        navBarColor = manifestAttributes.getNavBarColor()?.color ?? manifestAttributes.getPrimaryColor().color
        navBarControlColor = manifestAttributes.getNavBarControlColor()?.color ?? manifestAttributes.getPrimaryTextColor().color
        hidesChooseLanguageControl = parallelLanguage == nil || primaryLanguage.id == parallelLanguage?.id
        
        chooseLanguageControlPrimaryLanguageTitle = LanguageViewModel(language: primaryLanguage, localizationServices: localizationServices).translatedLanguageName
        
        let parallelLocalizedName: String
        if let parallelLanguage = parallelLanguage {
            parallelLocalizedName = LanguageViewModel(language: parallelLanguage, localizationServices: localizationServices).translatedLanguageName
        }
        else {
            parallelLocalizedName = ""
        }
        
        chooseLanguageControlParallelLanguageTitle = parallelLocalizedName
    }
}
