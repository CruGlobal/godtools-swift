//
//  ConfirmAppLanguageInterfaceStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 10/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ConfirmAppLanguageInterfaceStringsDomainModel {
    
    // TODO: - once our minimum deployment target is iOS 15, we can use AttributedString instead of NSAttributedString
    let messageInNewlySelectedLanguageHighlightModel: ConfirmAppLanguageHighlightStringDomainModel
    let messageInCurrentLanguageHighlightModel: ConfirmAppLanguageHighlightStringDomainModel
    let changeLanguageButtonText: String
    let nevermindButtonText: String
}
