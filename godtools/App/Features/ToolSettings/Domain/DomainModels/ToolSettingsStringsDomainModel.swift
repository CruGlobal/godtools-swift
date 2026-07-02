//
//  ToolSettingsStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolSettingsStringsDomainModel: Sendable {
    
    let chooseParallelLanguageActionTitle: String
    let title: String
    let shareLinkTitle: String
    let screenShareTitle: String
    let toolOptionEnableTrainingTips: String
    let toolOptionDisableTrainingTips: String
    let chooseLanguageTitle: String
    let chooseLanguageMessage: String
    let shareablesTitle: String
    
    static var emptyValue: ToolSettingsStringsDomainModel {
        return ToolSettingsStringsDomainModel(chooseParallelLanguageActionTitle: "", title: "", shareLinkTitle: "", screenShareTitle: "", toolOptionEnableTrainingTips: "", toolOptionDisableTrainingTips: "", chooseLanguageTitle: "", chooseLanguageMessage: "", shareablesTitle: "")
    }
}
