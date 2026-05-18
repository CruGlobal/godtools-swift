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
    case cardPrevButtonTitle = "card_status1"
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
    case networkConnectionLost = "network_connection_lost"
    case noInternet = "no_internet"
    case noInternetTitle = "no_internet_title"
    case ok = "OK"
    case requiredMissingField = "required_field_missing"
    case settings = "settings"
    case tutorialContinueButtonTitleCloseTutorial = "tutorial.continueButton.title.closeTutorial"
    case tutorialContinueButtonTitleContinue = "tutorial.continueButton.title.continue"
    case tutorialContinueButtonTitleStartUsingGodTools = "tutorial.continueButton.title.startUsingGodTools"
    case tutorialFindTutorialTitle = "tutorial.findTutorial.title"
    case tutorialLessonMessage = "tutorial.lesson.message"
    case tutorialLessonTitle = "tutorial.lesson.title"
    case tutorialScreenShareMessage = "tutorial.screenShare.message"
    case tutorialScreenShareTitle = "tutorial.screenShare.title"
    case tutorialToolMessage = "tutorial.tool.message"
    case tutorialToolTitle = "tutorial.tool.title"
    case tutorialToolTipMessage = "tutorial.toolTip.message"
    case tutorialToolTipTitle = "tutorial.toolTip.title"
}

extension LocalizableStringKeys {
    var key: String {
        return rawValue
    }
}
