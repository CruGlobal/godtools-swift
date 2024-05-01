//
//  LocalizableStringKeys.swift
//  godtools
//
//  Created by Levi Eggert on 4/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

enum LocalizableStringKeys: String {
    
    case languageSettingsNavTitle = "language_settings"
    case languageSettingsAppInterfaceTitle = "languageSettings.appInterface.title"
    case languageSettingsAppInterfaceMessage = "languageSettings.appInterface.message"
    case languageSettingsToolLanguagesAvailableOfflineTitle = "languageSettings.toolLanguagesAvailableOffline.title"
    case languageSettingsToolLanguagesAvailableOfflineMessage = "languageSettings.toolLanguagesAvailableOffline.message"
    case languageSettingsToolLanguagesAvailableOfflineEditDownloadedLanguagesButtonTitle = "languageSettings.toolLanguagesAvailableOffline.editDownloadedLanguagesButton.title"
}

extension LocalizableStringKeys {
    var key: String {
        return rawValue
    }
}
