//
//  AppFlowStep.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import UIKit
import GodToolsShared
import Combine
import Flow

@MainActor
enum AppFlowStep: FlowStep {
    
    // app
    case appLaunched(state: AppLaunchState)
    case deepLink(deepLinkType: ParsedDeepLinkType)
    case showDeferredDeepLinkModal
    case onboardingFlowCompleted(state: OnboardingFlow.CompletedState)
    case buttonWithUrlTappedFromAppMessage(url: URL)
    case menuTappedFromTools
    case openTutorialTappedFromTools
    
    // deferred deep link modal
    case closeTappedFromDeferredDeepLinkModal
    case handleDeepLinkFromDeferredDeepLinkModal(deepLinkType: ParsedDeepLinkType)
    
    // onboarding
    case chooseAppLanguageTappedFromOnboardingTutorial
    case videoButtonTappedFromOnboardingTutorial(youtubeVideoId: String)
    case closeVideoPlayerTappedFromOnboardingTutorial
    case videoEndedOnOnboardingTutorial
    case continueTappedFromOnboardingTutorial
    case skipTappedFromOnboardingTutorial
    case endTutorialFromOnboardingTutorial
    
    // lessons list
    case lessonLanguageFilterTappedFromLessons
    case personalizedLessonLanguageFilterTappedFromLessons
    case lessonTappedFromLessonsList(lessonListItem: LessonListItemDomainModel, languageFilter: ToolLanguageFilterItemDomainModel?)
    case changeLocalizationSettingsTappedFromLessons
    
    // lesson filter language
    case backTappedFromLessonLanguageFilter
    case languageTappedFromLessonLanguageFilter
    
    // personalized lesson filter language
    case backTappedFromPersonalizedLessonLanguageFilter
    case languageTappedFromPersonalizedLanguageFilter

    // lesson
    case closeLessonSwipeTutorial
    case startOverTappedFromResumeLessonModal(toolTranslations: ToolTranslationsDomainModel)
    case continueTappedFromResumeLessonModal(toolTranslations: ToolTranslationsDomainModel)
    case shareLessonTappedFromLesson(pageNumber: Int, languageId: String)
    case closeTappedFromLesson(lessonId: String, lessonLanguage: String, highestPageNumberViewed: Int)
    case lessonFlowCompleted(state: LessonFlow.CompletedState)
    
    // lesson evaluation
    case closeTappedFromLessonEvaluation
    case sendFeedbackTappedFromLessonEvaluation
    case backgroundTappedFromLessonEvaluation
    
    // favorites
    case featuredLessonTappedFromFavorites(featuredLesson: FeaturedLessonDomainModel)
    case viewAllFavoriteToolsTappedFromFavorites
    case toolDetailsTappedFromFavorites(tool: YourFavoritedToolDomainModel)
    case openToolTappedFromFavorites(tool: YourFavoritedToolDomainModel)
    case toolTappedFromFavorites(tool: YourFavoritedToolDomainModel)
    case unfavoriteToolTappedFromFavorites(tool: YourFavoritedToolDomainModel)
    case goToToolsTappedFromFavorites
    
    // allYourFavoritedTools
    case backTappedFromAllYourFavoriteTools
    case toolDetailsTappedFromAllYourFavoriteTools(tool: YourFavoritedToolDomainModel)
    case openToolTappedFromAllYourFavoriteTools(tool: YourFavoritedToolDomainModel)
    case toolTappedFromAllYourFavoritedTools(tool: YourFavoritedToolDomainModel)
    case unfavoriteToolTappedFromAllYourFavoritedTools(tool: YourFavoritedToolDomainModel, didConfirmToolRemovalSubject: PassthroughSubject<Void, Never>)
    
    // tools
    case toolCategoryFilterTappedFromTools
    case toolLanguageFilterTappedFromTools
    case categoryTappedFromToolCategoryFilter
    case languageTappedFromToolLanguageFilter
    case backTappedFromToolCategoryFilter
    case backTappedFromToolLanguageFilter
    case spotlightToolTappedFromTools(spotlightTool: SpotlightToolListItemDomainModel, toolFilterLanguage: ToolFilterLanguageDomainModel?)
    case toolTappedFromTools(tool: ToolListItemDomainModel, toolFilterLanguage: ToolFilterLanguageDomainModel?)
    case changeLocalizationSettingsTappedFromTools
    
    // toolDetails
    case backTappedFromToolDetails
    case openToolTappedFromToolDetails(tool: ToolDetailsTool)
    case learnToShareToolTappedFromToolDetails(tool: ToolDetailsTool)
    case urlLinkTappedFromToolDetails(urlLinkTapped: URLLinkTappedParams)
    
    // learnToShareTool
    case closeTappedFromLearnToShareTool(tool: ToolDetailsTool)
    case startTrainingTappedFromLearnToShareTool(tool: ToolDetailsTool)
            
    // tool
    case homeTappedFromTool(isScreenSharing: Bool)
    case backTappedFromTool(isScreenSharing: Bool)
    case toolSettingsTappedFromTool(toolSettingsObserver: ToolSettingsObserver, toolSettingsDidCloseClosure: (() -> Void)?)
    case tractFlowCompleted(state: TractFlow.CompletedState)
    case acceptTappedFromExitToolRemoteShare
       
    // optInNotification
    case closeTappedFromOptInNotification
    case allowNotificationsTappedFromOptInNotification
    case settingsTappedFromOptInNotification
    case maybeLaterTappedFromOptInNotification
    case dontAllowTappedFromRequestNotificationPermission
    case allowTappedFromRequestNotificationPermission
    case optInNotificationFlowCompleted(state: OptInNotificationFlow.CompletedState)
    
    // tutorial
    case closeTappedFromTutorial
    case continueTappedFromTutorial
    case startUsingGodToolsTappedFromTutorial
    case tutorialFlowCompleted(state: TutorialFlow.CompletedState)
    
    // menu
    case doneTappedFromMenu
    case tutorialTappedFromMenu
    case languageSettingsTappedFromMenu
    case localizationSettingsTappedFromMenu
    case loginTappedFromMenu
    case createAccountTappedFromMenu
    case activityTappedFromMenu
    case sendFeedbackTappedFromMenu
    case backTappedFromSendFeedback
    case reportABugTappedFromMenu
    case backTappedFromReportABug
    case askAQuestionTappedFromMenu
    case backTappedFromAskAQuestion
    case leaveAReviewTappedFromMenu(screenName: String, siteSection: String, siteSubSection: String, contentLanguage: String?, contentLanguageSecondary: String?)
    case shareAStoryWithUsTappedFromMenu
    case backTappedFromShareAStoryWithUs
    case shareGodToolsTappedFromMenu
    case dismissedShareGodToolsActivityViewController
    case termsOfUseTappedFromMenu
    case backTappedFromTermsOfUse
    case privacyPolicyTappedFromMenu
    case backTappedFromPrivacyPolicy
    case copyrightInfoTappedFromMenu
    case backTappedFromCopyrightInfo
    case deleteAccountTappedFromMenu
    case copyFirebaseDeviceTokenTappedFromMenu
        
    // user activity
    case backTappedFromActivity
    
    // social sign-in
    case closeTappedFromLogin
    case closeTappedFromCreateAccount
    case userCompletedSignInFromLogin(error: AuthErrorDomainModel?)
    case userCompletedSignInFromCreateAccount(error: AuthErrorDomainModel?)
        
    // delete account
    case closeTappedFromDeleteAccount
    case deleteAccountTappedFromDeleteAccount
    case cancelTappedFromDeleteAccount
    case deleteAccountTappedFromConfirmDeleteAccount
    
    // delete account progress
    case didFinishAccountDeletionWithSuccessFromDeleteAccountProgress
    case didFinishAccountDeletionWithErrorFromDeleteAccountProgress(error: Error)
    
    // language settings
    case backTappedFromLanguageSettings
    case languageSettingsFlowCompleted(state: LanguageSettingsFlow.CompletedState)
    case chooseAppLanguageTappedFromLanguageSettings
    case editDownloadedLanguagesTappedFromLanguageSettings
    
    // choose app language
    case backTappedFromAppLanguages
    case appLanguageTappedFromAppLanguages(appLanguage: AppLanguageListItemDomainModel)
    case appLanguageChangeConfirmed(appLanguage: AppLanguageListItemDomainModel)
    case nevermindTappedFromConfirmAppLanguageChange
    case backTappedFromConfirmAppLanguageChange
    case chooseAppLanguageFlowCompleted(state: ChooseAppLanguageFlow.CompletedState)
    
    // downloaded languages
    case backTappedFromDownloadedLanguages
    
    // article categories
    case backTappedFromArticleCategories
    case articleCategoryTappedFromArticleCategories(resource: ResourceDataModel, language: LanguageDataModel, category: ArticleCategoryDomainModel, manifest: Manifest)
    case backTappedFromArticles
    case articleTappedFromArticles(resource: ResourceDataModel, articleId: String)
    case articleCategoriesFlowCompleted(state: ArticleCategoriesFlow.CompletedState)
    
    // article
    case backTappedFromArticle
    case sharedTappedFromArticle(articleId: String)
    case dismissedShareArticleActivityViewController
    case debugTappedFromArticle(articleUrl: ArticleUrlDomainModel)
    case closeTappedFromArticleDebug
    case articleFlowCompleted(state: ArticleFlow.CompletedState)
    
    // load article
    case didDownloadArticleFromLoadingArticle(aemUri: String)
    case didFailToDownloadArticleFromLoadingArticle(alertMessage: AlertMessage)
    case loadingArticleFlowCompleted(state: LoadingArticleFlow.CompletedState)
    
    // choose your own adventure
    case toolSettingsTappedFromChooseYourOwnAdventure(toolSettingsObserver: ToolSettingsObserver)
    case backTappedFromChooseYourOwnAdventure
    case chooseYourOwnAdventureFlowCompleted(state: ChooseYourOwnAdventureFlow.CompletedState)
        
    // tool settings
    case closeTappedFromToolSettings
    case shareLinkTappedFromToolSettings
    case screenShareTappedFromToolSettings
    case primaryLanguageTappedFromToolSettings
    case parallelLanguageTappedFromToolSettings
    case toolSettingsFlowCompleted(state: ToolSettingsFlow.CompletedState)
    
    // tool settings - tool languages list
    case closeTappedFromToolSettingsToolLanguagesList
    case primaryLanguageTappedFromToolSettingsToolLanguagesList
    case parallelLanguageTappedFromToolSettingsToolLanguagesList
    case deleteParallelLanguageTappedFromToolSettingsToolLanguagesList
    
    // tool settings - tool screen share
    case closeTappedFromToolScreenShareTutorial
    case generateQRCodeTappedFromToolScreenShareTutorial
    case shareLinkTappedFromToolScreenShareTutorial
    case closeTappedFromCreatingToolScreenShareSession
    case didCreateSessionFromCreatingToolScreenShareSession(result: Result<WebSocketChannel, Error>, createSessionTrigger: ToolScreenShareFlowCreateSessionTrigger)
    case shareQRCodeTappedFromToolScreenShareSession(shareUrl: String)
    case dismissedShareToolScreenShareActivityViewController
    case closeTappedFromShareToolScreenQRCode
    
    // too settings - share shareable
    case shareableTappedFromToolSettings(shareable: ShareableDomainModel)
    case closeTappedFromReviewShareShareable
    case shareImageTappedFromReviewShareShareable(shareImage: UIImage)
    case dismissedShareShareableActivityViewController
    
    // tool navigation
    case toolNavigationFlowCompleted(state: ToolNavigationFlow.CompletedState)
    
    // download tool
    case downloadToolSuccess(toolTranslations: ToolTranslationsDomainModel)
    case downloadToolFailed(error: Error)
    case closeTappedFromDownloadTool
    case downloadToolFlowCompleted(state: DownloadToolFlow.CompletedState)
    
    // localization settings
    case localizationSettingsFlowCompleted(state: LocalizationSettingsFlow.CompletedState)
    case backTappedFromLocalizationSettings
    case countryTappedFromLocalizationSettings(country: LocalizationSettingsCountryListItem)
    case closeTappedFromLocalizationConfirmation
    case cancelTappedFromLocalizationConfirmation
    case confirmTappedFromLocalizationConfirmation(country: LocalizationSettingsCountryListItem)
    
    // share tool
    case qrCodeTappedFromShareTool
    case dismissedShareTool
    case shareToolFlowCompleted(state: ShareToolFlow.CompletedState)
    case closedTappedFromShareToolQrCode
}
