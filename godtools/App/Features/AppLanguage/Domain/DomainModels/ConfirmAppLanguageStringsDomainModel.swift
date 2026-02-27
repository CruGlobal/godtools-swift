//
//  ConfirmAppLanguageStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 10/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ConfirmAppLanguageStringsDomainModel: Sendable {
    
    let messageInNewlySelectedLanguageHighlightModel: ConfirmAppLanguageHighlightStringDomainModel
    let messageInCurrentLanguageHighlightModel: ConfirmAppLanguageHighlightStringDomainModel
    let changeLanguageButtonText: String
    let nevermindButtonText: String
    
    static var emptyValue: ConfirmAppLanguageStringsDomainModel {
        return ConfirmAppLanguageStringsDomainModel(messageInNewlySelectedLanguageHighlightModel: ConfirmAppLanguageHighlightStringDomainModel.emptyStrings(), messageInCurrentLanguageHighlightModel: ConfirmAppLanguageHighlightStringDomainModel.emptyStrings(), changeLanguageButtonText: "", nevermindButtonText: "")
    }
}
