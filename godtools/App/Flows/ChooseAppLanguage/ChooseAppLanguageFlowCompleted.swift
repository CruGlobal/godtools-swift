//
//  ChooseAppLanguageFlowCompleted.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum ChooseAppLanguageFlowCompleted {
    
    case userChoseAppLanguage(appLanguage: AppLanguageListItemDomainModel)
    case userClosedChooseAppLanguage
}
