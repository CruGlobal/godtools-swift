//
//  DeleteLanguageListItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DeleteLanguageListItemViewModel: BaseLanguagesListItemViewModel {
    
    init(localizationServices: LocalizationServices) {
        
        super.init()
        
        self.name = localizationServices.stringForSystemElseEnglish(key: "toolSettings.languagesList.deleteLanguage.title")
        self.isSelected = false
    }
}
