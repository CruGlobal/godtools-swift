//
//  LanguageNameViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LanguageNameViewModel {

    let name: String
    
    init(language: LanguageModelType) {
                
        let localizedNameKey: String = "language_name_" + language.code
        let localizedName: String = NSLocalizedString(localizedNameKey, comment: "")
        
        if !localizedName.isEmpty && localizedName != localizedNameKey {
            name = localizedName
        }
        else if let localeName = Locale.current.localizedString(forIdentifier: language.code), !localeName.isEmpty {
            name = localeName
        }
        else if !language.name.isEmpty {
            name = language.name
        }
        else {
            name = language.code
        }
    }
}
