//
//  LocalizableStringKeys.swift
//  godtools
//
//  Created by Levi Eggert on 4/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

enum LocalizableStringKeys: String {
    
    case accountDeletedAlertTitle = "accountDeletedAlert.title"
    case accountDeletedAlertMessage = "accountDeletedAlert.message"
    case alertMailAppUnavailableTitle = "alert.mailAppUnavailable.title"
    case alertMailAppUnavailableMessage = "alert.mailAppUnavailable.message"
    case articlesRetryDownloadButtonTitle = "articles.downloadArticlesButton.title.retryDownload"
    case cancel = "cancel"
    case cardNextButtonTitle = "card_status2"
    case close = "close"
    case confirmDeleteAccountTitle = "confirmDeleteAccount.title"
    case confirmDeleteAccountConfirmButtonTitle = "confirmDeleteAccount.confirmButton.title"
    case downloadError = "download_error"
    case downloadInProgress = "Download in progress"
    case error = "error"
    case languageSettingsNavTitle = "language_settings"
    case languageSettingsAppInterfaceTitle = "languageSettings.appInterface.title"
    case languageSettingsAppInterfaceMessage = "languageSettings.appInterface.message"
    case languageSettingsToolLanguagesAvailableOfflineTitle = "languageSettings.toolLanguagesAvailableOffline.title"
    case languageSettingsToolLanguagesAvailableOfflineMessage = "languageSettings.toolLanguagesAvailableOffline.message"
    case languageSettingsToolLanguagesAvailableOfflineEditDownloadedLanguagesButtonTitle = "languageSettings.toolLanguagesAvailableOffline.editDownloadedLanguagesButton.title"
    case noInternet = "no_internet"
    case noInternetTitle = "no_internet_title"
    case ok = "OK"
    case requiredMissingField = "required_field_missing"
}

extension LocalizableStringKeys {
    var key: String {
        return rawValue
    }
}
