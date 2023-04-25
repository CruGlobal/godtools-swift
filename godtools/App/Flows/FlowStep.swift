//
//  FlowStep.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

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
    case userViewedFavoritedToolsListFromTools
    case userViewedAllToolsListFromTools
    
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
    
    // favoritedTools
    case lessonTappedFromFeaturedLessons(lesson: LessonDomainModel)
    case viewAllFavoriteToolsTappedFromFavoritedTools
    case backTappedFromAllFavoriteTools
    case toolTappedFromFavoritedTools(resource: ResourceModel)
    case aboutToolTappedFromFavoritedTools(resource: ResourceModel)
    case unfavoriteToolTappedFromFavoritedTools(resource: ResourceModel, removeHandler: CallbackHandler)
    case allToolsTappedFromFavoritedTools
    
    // allTools
    case toolTappedFromAllTools(resource: ResourceModel)
    case aboutToolTappedFromAllTools(resource: ResourceModel)
    
    // toolDetails
    case backTappedFromToolDetails
    case openToolTappedFromToolDetails(resource: ResourceModel)
    case learnToShareToolTappedFromToolDetails(resource: ResourceModel)
    case urlLinkTappedFromToolDetail(url: URL, exitLink: ExitLinkModel)
    
    // learnToShareTool
    case closeTappedFromLearnToShareTool(resource: ResourceModel)
    case continueTappedFromLearnToShareTool(resource: ResourceModel)
            
    // tool
    case homeTappedFromTool(isScreenSharing: Bool)
    case toolSettingsTappedFromTool(toolData: ToolSettingsFlowToolData)
    case tractFlowCompleted(state: TractFlowCompletedState)
        
    // setup parallel language
    case languageSelectorTappedFromSetupParallelLanguage
    case yesTappedFromSetupParallelLanguage
    case noThanksTappedFromSetupParallelLanguage
    case getStartedTappedFromSetupParallelLanguage
    case languageSelectedFromParallelLanguageList
    case backgroundTappedFromSetupParallelLanguage
    case backgroundTappedFromParallelLanguageList
        
    // tutorial
    case closeTappedFromTutorial
    case startUsingGodToolsTappedFromTutorial
    
    // menu
    case doneTappedFromMenu
    case tutorialTappedFromMenu
    case languageSettingsTappedFromMenu
    case loginTappedFromMenu
    case backTappedFromLogin
    case createAccountTappedFromMenu
    case backTappedFromCreateAccount
    case activityTappedFromMenu
    case sendFeedbackTappedFromMenu
    case backTappedFromSendFeedback
    case reportABugTappedFromMenu
    case backTappedFromReportABug
    case askAQuestionTappedFromMenu
    case backTappedFromAskAQuestion
    case leaveAReviewTappedFromMenu
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
    
    // delete account
    case backTappedFromDeleteAccount
    case emailHelpDeskToDeleteOktaAccountTappedFromDeleteAccount
    
    // language settings
    case backTappedFromLanguageSettings
    case choosePrimaryLanguageTappedFromLanguageSettings
    case chooseParallelLanguageTappedFromLanguageSettings
    case backTappedFromChooseLanguage
    case languageTappedFromChooseLanguage
    case deleteLanguageTappedFromChooseLanguage
    case languageSettingsFlowCompleted(state: LanguageSettingsFlowCompletedState)
    
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
