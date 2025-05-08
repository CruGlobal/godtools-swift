//
//  FlowStep.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser
import Combine

enum FlowStep {
    
    // app
    case appLaunched(state: AppLaunchState)
    case deepLink(deepLinkType: ParsedDeepLinkType)
    case showOnboardingTutorial(animated: Bool)
    case onboardingFlowCompleted(onboardingFlowCompletedState: OnboardingFlowCompletedState?)
    case buttonWithUrlTappedFromAppMessage(url: URL)
    case menuTappedFromTools
    case openTutorialTappedFromTools
    
    // onboarding
    case chooseAppLanguageTappedFromOnboardingTutorial
    case videoButtonTappedFromOnboardingTutorial(youtubeVideoId: String)
    case closeVideoPlayerTappedFromOnboardingTutorial
    case videoEndedOnOnboardingTutorial
    case skipTappedFromOnboardingTutorial
    case endTutorialFromOnboardingTutorial
    
    // lessons list
    case lessonLanguageFilterTappedFromLessons
    case lessonTappedFromLessonsList(lessonListItem: LessonListItemDomainModel, languageFilter: LessonFilterLanguageDomainModel?)
    case languageTappedFromLessonLanguageFilter
    case backTappedFromLessonLanguageFilter

    // lesson
    case closeLessonSwipeTutorial
    case startOverTappedFromResumeLessonModal
    case continueTappedFromResumeLessonModal
    case closeTappedFromLesson(lessonId: String, highestPageNumberViewed: Int)
    case lessonFlowCompleted(state: LessonFlowCompletedState)
    
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
    
    // toolDetails
    case backTappedFromToolDetails
    case openToolTappedFromToolDetails(toolId: String, primaryLanguage: AppLanguageDomainModel, parallelLanguage: AppLanguageDomainModel?, selectedLanguageIndex: Int?)
    case learnToShareToolTappedFromToolDetails(toolId: String, primaryLanguage: AppLanguageDomainModel, parallelLanguage: AppLanguageDomainModel?, selectedLanguageIndex: Int?)
    case urlLinkTappedFromToolDetail(url: URL, screenName: String, siteSection: String, siteSubSection: String, contentLanguage: String?, contentLanguageSecondary: String?)
    
    // learnToShareTool
    case closeTappedFromLearnToShareTool(toolId: String, primaryLanguage: AppLanguageDomainModel, parallelLanguage: AppLanguageDomainModel?, selectedLanguageIndex: Int?)
    case continueTappedFromLearnToShareTool(toolId: String, primaryLanguage: AppLanguageDomainModel, parallelLanguage: AppLanguageDomainModel?, selectedLanguageIndex: Int?)
            
    // tool
    case homeTappedFromTool(isScreenSharing: Bool)
    case backTappedFromTool
    case toolSettingsTappedFromTool(toolSettingsObserver: ToolSettingsObserver, toolSettingsDidCloseClosure: (() -> Void)?)
    case tractFlowCompleted(state: TractFlowCompletedState)
    case acceptTappedFromExitToolRemoteShare
       
    // optInNotification
    case closeTappedFromOptInNotification
    case allowNotificationsTappedFromOptInNotification
    case settingsTappedFromOptInNotification
    case maybeLaterTappedFromOptInNotification
    case dontAllowTappedFromRequestNotificationPermission
    case allowTappedFromRequestNotificationPermission
    case optInNotificationFlowCompleted(state: OptInNotificationFlowCompletedState)
    
    // tutorial
    case closeTappedFromTutorial
    case startUsingGodToolsTappedFromTutorial
    
    // menu
    case doneTappedFromMenu
    case tutorialTappedFromMenu
    case languageSettingsTappedFromMenu
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
    case languageSettingsFlowCompleted(state: LanguageSettingsFlowCompletedState)
    case chooseAppLanguageTappedFromLanguageSettings
    case editDownloadedLanguagesTappedFromLanguageSettings
    
    // choose app language
    case backTappedFromAppLanguages
    case appLanguageTappedFromAppLanguages(appLanguage: AppLanguageListItemDomainModel)
    case appLanguageChangeConfirmed(appLanguage: AppLanguageListItemDomainModel)
    case nevermindTappedFromConfirmAppLanguageChange
    case backTappedFromConfirmAppLanguageChange
    case chooseAppLanguageFlowCompleted(state: ChooseAppLanguageFlowCompleted)
    
    // downloaded languages
    case backTappedFromDownloadedLanguages
    case languageDownloadFailedFromDownloadedLanguages(error: Error)
    
    // article
    case backTappedFromArticleCategories
    case articleCategoryTappedFromArticleCategories(resource: ResourceModel, language: LanguageModel, category: GodToolsToolParser.Category, manifest: Manifest, currentArticleDownloadReceipt: ArticleManifestDownloadArticlesReceipt?)
    case backTappedFromArticles
    case articleTappedFromArticles(resource: ResourceModel, aemCacheObject: ArticleAemCacheObject)
    case backTappedFromArticle
    case sharedTappedFromArticle(articleAemData: ArticleAemData)
    case articleFlowCompleted(state: ArticleFlowCompletedState)
    case debugTappedFromArticle(article: ArticleDomainModel)
    case closeTappedFromArticleDebug
    
    // article deep link
    case didDownloadArticleFromLoadingArticle(aemCacheObject: ArticleAemCacheObject)
    case didFailToDownloadArticleFromLoadingArticle(alertMessage: AlertMessageType)
    
    // choose your own adventure
    case toolSettingsTappedFromChooseYourOwnAdventure(toolSettingsObserver: ToolSettingsObserver)
    case backTappedFromChooseYourOwnAdventure
    case chooseYourOwnAdventureFlowCompleted(state: ChooseYourOwnAdventureFlowCompletedState)
        
    // tool settings
    case closeTappedFromToolSettings
    case shareLinkTappedFromToolSettings
    case screenShareTappedFromToolSettings
    case primaryLanguageTappedFromToolSettings
    case parallelLanguageTappedFromToolSettings
    case shareableTappedFromToolSettings(shareable: ShareableDomainModel)
    case closeTappedFromReviewShareShareable
    case shareImageTappedFromReviewShareShareable(shareImage: UIImage)
    case toolSettingsFlowCompleted(state: ToolSettingsFlowCompletedState)
    
    // tool settings tool languages list
    case closeTappedFromToolSettingsToolLanguagesList
    case primaryLanguageTappedFromToolSettingsToolLanguagesList
    case parallelLanguageTappedFromToolSettingsToolLanguagesList
    case deleteParallelLanguageTappedFromToolSettingsToolLanguagesList
    
    // tool screen share
    case closeTappedFromToolScreenShareTutorial
    case skipTappedFromToolScreenShareTutorial
    case shareLinkTappedFromToolScreenShareTutorial
    case closeTappedFromCreatingToolScreenShareSession
    case didCreateSessionFromCreatingToolScreenShareSession(result: Result<WebSocketChannel, TractRemoteSharePublisherError>)
    case toolScreenShareFlowCompleted(state: ToolScreenShareFlowCompletedState)
    
    // download tool
    case closeTappedFromDownloadToolProgress
}
