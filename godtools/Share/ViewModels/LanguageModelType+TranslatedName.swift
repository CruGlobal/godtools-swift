//
//  LanguageModelType+TranslatedName.swift
//  godtools
//
//  Created by Levi Eggert on 6/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

extension LanguageModelType {
    
    func translatedName(translateLanguageNameViewModel: TranslateLanguageNameViewModel) -> String {
        
        return translateLanguageNameViewModel.getTranslatedName(language: self)
    }
}
