//
//  LanguageSettingsStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct LanguageSettingsStringsDomainModel: Sendable {
    
    let navTitle: String
    let appInterfaceLanguageTitle: String
    let numberOfAppLanguagesAvailable: String
    let setAppLanguageMessage: String
    let chooseAppLanguageButtonTitle: String
    let toolLanguagesAvailableOfflineTitle: String
    let downloadToolsForOfflineMessage: String
    let editDownloadedLanguagesButtonTitle: String
    
    static var emptyValue: LanguageSettingsStringsDomainModel {
        return LanguageSettingsStringsDomainModel(navTitle: "", appInterfaceLanguageTitle: "", numberOfAppLanguagesAvailable: "", setAppLanguageMessage: "", chooseAppLanguageButtonTitle: "", toolLanguagesAvailableOfflineTitle: "", downloadToolsForOfflineMessage: "", editDownloadedLanguagesButtonTitle: "")
    }
}
