//
//  DetermineNewUserIfPrimaryLanguageSet.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct DetermineNewUserIfPrimaryLanguageSet: DetermineIfNewUserType {
    
    let isNewUser: Bool
    
    init(languageManager: LanguagesManager) {
        isNewUser = languageManager.loadPrimaryLanguageFromDisk() == nil
    }
}
