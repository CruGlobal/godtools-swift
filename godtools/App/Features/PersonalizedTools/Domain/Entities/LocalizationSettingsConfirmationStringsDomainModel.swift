//
//  LocalizationSettingsConfirmationStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct LocalizationSettingsConfirmationStringsDomainModel {

    let titleHighlightModel: ConfirmAppLanguageHighlightStringDomainModel
    let description: String
    let detail: String
    let cancelButton: String
    let confirmButton: String

    static var emptyValue: LocalizationSettingsConfirmationStringsDomainModel {
        return LocalizationSettingsConfirmationStringsDomainModel(
            titleHighlightModel: ConfirmAppLanguageHighlightStringDomainModel.emptyStrings(),
            description: "",
            detail: "",
            cancelButton: "",
            confirmButton: ""
        )
    }
}
