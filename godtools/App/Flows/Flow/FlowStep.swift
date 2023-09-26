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
    case appLaunchedFromTerminatedState
    case appLaunchedFromBackgroundState
    case deepLink(deepLinkType: ParsedDeepLinkType)
    case showOnboardingTutorial(animated: Bool)
    case onboardingFlowCompleted(onboardingFlowCompletedState: OnboardingFlowCompletedState?)
    case buttonWithUrlTappedFromFirebaseInAppMessage(url: URL)
    case menuTappedFromTools
    case languageSettingsTappedFromTools
    case openTutorialTappedFromTools
    
    // onboarding
    case videoButtonTappedFromOnboardingTutorial(youtubeVideoId: String)
    case closeVideoPlayerTappedFromOnboardingTutorial
    case videoEndedOnOnboardingTutorial
    case skipTappedFromOnboardingTutorial
    case endTutorialFromOnboardingTutorial
    case skipTappedFromOnboardingQuickStart
    case endTutorialFromOnboardingQuickStart
    case readArticlesTappedFromOnboardingQuickStart
    case tryLessonsTappedFromOnboardingQuickStart
    case chooseToolTappedFromOnboardingQuickStart
    
    // lessons list
    case lessonTappedFromLessonsList(lesson: LessonDomainModel)
    
    // lesson
    case closeTappedFromLesson(lesson: ResourceModel, highestPageNumberViewed: Int)
    case lessonFlowCompleted(state: LessonFlowCompletedState)
    
    // lesson evaluation
    case closeTappedFromLessonEvaluation
    case sendFeedbackTappedFromLessonEvaluation
    case backgroundTappedFromLessonEvaluation
    
    // favorites
    case lessonTappedFromFavorites(lesson: LessonDomainModel)
    case viewAllFavoriteToolsTappedFromFavorites
    case toolDetailsTappedFromFavorites(tool: ToolDomainModel)
    case openToolTappedFromFavorites(tool: ToolDomainModel)
    case toolTappedFromFavorites(tool: ToolDomainModel)
    case unfavoriteToolTappedFromFavorites(tool: ToolDomainModel)
    case goToToolsTappedFromFavorites
    
    // allYourFavoritedTools
    case backTappedFromAllYourFavoriteTools
    case toolDetailsTappedFromAllYourFavoriteTools(tool: ToolDomainModel)
    case openToolTappedFromAllYourFavoriteTools(tool: ToolDomainModel)
    case toolTappedFromAllYourFavoritedTools(tool: ToolDomainModel)
    case unfavoriteToolTappedFromAllYourFavoritedTools(tool: ToolDomainModel, didConfirmToolRemovalSubject: PassthroughSubject<Void, Never>)
    
    // tools
    case toolFilterTappedFromTools(toolFilterType: ToolFilterType, currentToolFilterSelection: ToolFilterSelection)
    case backTappedFromToolFilter
    case toolTappedFromTools(resource: ResourceModel)
    
    // toolDetails
    case backTappedFromToolDetails
    case openToolTappedFromToolDetails(resource: ResourceModel)
    case learnToShareToolTappedFromToolDetails(resource: ResourceModel)
    case urlLinkTappedFromToolDetail(url: URL, screenName: String, siteSection: String, siteSubSection: String, contentLanguage: String?, contentLanguageSecondary: String?)
    
    // learnToShareTool
    case closeTappedFromLearnToShareTool(resource: ResourceModel)
    case continueTappedFromLearnToShareTool(resource: ResourceModel)
            
    // tool
    case homeTappedFromTool(isScreenSharing: Bool)
    case toolSettingsTappedFromTool(toolData: ToolSettingsFlowToolData)
    case tractFlowCompleted(state: TractFlowCompletedState)
        
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
    case chooseAppLanguageTappedFromLanguageSettings(didChooseAppLanguageSubject: PassthroughSubject<AppLanguageListItemDomainModel, Never>)
    
    // choose app language
    case backTappedFromAppLanguages
    case appLanguageTappedFromAppLanguages(appLanguage: AppLanguageListItemDomainModel)
    case chooseAppLanguageFlowCompleted(state: ChooseAppLanguageFlowCompleted)
    
    // article
    case backTappedFromArticleCategories
    case articleCategoryTappedFromArticleCategories(resource: ResourceModel, language: LanguageDomainModel, category: GodToolsToolParser.Category, manifest: Manifest, currentArticleDownloadReceipt: ArticleManifestDownloadArticlesReceipt?)
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
    case backTappedFromChooseYourOwnAdventure
    case chooseYourOwnAdventureFlowCompleted(state: ChooseYourOwnAdventureFlowCompletedState)
        
    // tool settings
    case closeTappedFromToolSettings
    case shareLinkTappedFromToolSettings
    case screenShareTappedFromToolSettings
    case closeTappedFromShareToolScreenTutorial
    case shareLinkTappedFromShareToolScreenTutorial
    case finishedLoadingToolRemoteSession(result: Result<TractRemoteShareChannel, TractRemoteSharePublisherError>)
    case cancelledLoadingToolRemoteSession
    case enableTrainingTipsTappedFromToolSettings
    case disableTrainingTipsTappedFromToolSettings
    case primaryLanguageTappedFromToolSettings
    case parallelLanguageTappedFromToolSettings
    case swapLanguagesTappedFromToolSettings
    case shareableTappedFromToolSettings(shareableImageDomainModel: ShareableImageDomainModel)
    case closeTappedFromReviewShareShareable
    case shareImageTappedFromReviewShareShareable(shareImage: UIImage)
    case toolSettingsFlowCompleted
    
    // download tool
    case closeTappedFromDownloadToolProgress
}
