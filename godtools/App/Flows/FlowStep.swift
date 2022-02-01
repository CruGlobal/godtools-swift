//
//  FlowStep.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum FlowStep {
    
    // app
    case appLaunchedFromTerminatedState
    case appLaunchedFromBackgroundState
    case deepLink(deepLinkType: ParsedDeepLinkType)
    case showTools(animated: Bool, shouldCreateNewInstance: Bool, startingToolbarItem: ToolsMenuToolbarView.ToolbarItemView?)
    case showMenu
    case showLanguageSettings
    case showOnboardingTutorial(animated: Bool)
    case onboardingFlowCompleted(onboardingFlowCompletedState: OnboardingFlowCompletedState?)
    case showSetupParallelLanguage
    case buttonWithUrlTappedFromFirebaseInAppMessage(url: URL)
    
    // tools
    case menuTappedFromTools
    case languageSettingsTappedFromTools
    case openTutorialTapped
    
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
    case lessonTappedFromLessonsList(resource: ResourceModel)
    
    // lesson
    case closeTappedFromLesson(lesson: ResourceModel, highestPageNumberViewed: Int)
    case lessonFlowCompleted(state: LessonFlowCompletedState)
    
    // lesson evaluation
    case closeTappedFromLessonEvaluation
    case sendFeedbackTappedFromLessonEvaluation
    case backgroundTappedFromLessonEvaluation
    
    // favoritedTools
    case toolTappedFromFavoritedTools(resource: ResourceModel)
    case aboutToolTappedFromFavoritedTools(resource: ResourceModel)
    case unfavoriteToolTappedFromFavoritedTools(resource: ResourceModel, removeHandler: CallbackHandler)
    
    // allTools
    case toolTappedFromAllTools(resource: ResourceModel)
    case aboutToolTappedFromAllTools(resource: ResourceModel)
    
    // toolDetails
    case openToolTappedFromToolDetails(resource: ResourceModel)
    case learnToShareToolTappedFromToolDetails(resource: ResourceModel)
    case urlLinkTappedFromToolDetail(url: URL, exitLink: ExitLinkModel)
    
    // learnToShareTool
    case closeTappedFromLearnToShareTool(resource: ResourceModel)
    case continueTappedFromLearnToShareTool(resource: ResourceModel)
        
    // tool
    case homeTappedFromTool(isScreenSharing: Bool)
    case shareMenuTappedFromTool(tractRemoteShareSubscriber: TractRemoteShareSubscriber, tractRemoteSharePublisher: TractRemoteSharePublisher, resource: ResourceModel, selectedLanguage: LanguageModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, pageNumber: Int)
    case buttonWithUrlTappedFromMobileContentRenderer(url: String, exitLink: ExitLinkModel)
    case trainingTipTappedFromMobileContentRenderer(event: TrainingTipEvent)
    case errorOccurredFromMobileContentRenderer(error: MobileContentErrorViewModel)
    case tractFlowCompleted(state: TractFlowCompletedState)
    
    // tool training
    case closeTappedFromToolTraining
    
    // setup parallel language
    case languageSelectorTappedFromSetupParallelLanguage
    case yesTappedFromSetupParallelLanguage
    case noThanksTappedFromSetupParallelLanguage
    case getStartedTappedFromSetupParallelLanguage
    case languageSelectedFromParallelLanguageList
    case backgroundTappedFromSetupParallelLanguage
    case backgroundTappedFromParallelLanguageList
    
    // share tool menu
    case shareToolTappedFromShareToolMenu
    case remoteShareToolTappedFromShareToolMenu
    case closeTappedFromShareToolScreenTutorial
    case shareLinkTappedFromShareToolScreenTutorial
    case finishedLoadingToolRemoteSession(result: Result<TractRemoteShareChannel, TractRemoteSharePublisherError>)
    case cancelledLoadingToolRemoteSession
    
    // tutorial
    case closeTappedFromTutorial
    case startUsingGodToolsTappedFromTutorial
    
    // menu
    case doneTappedFromMenu
    case languageSettingsTappedFromMenu
    case tutorialTappedFromMenu
    case myAccountTappedFromMenu
    case aboutTappedFromMenu
    case helpTappedFromMenu
    case contactUsTappedFromMenu
    case shareGodToolsTappedFromMenu
    case shareAStoryWithUsTappedFromMenu
    case termsOfUseTappedFromMenu
    case privacyPolicyTappedFromMenu
    case copyrightInfoTappedFromMenu
    
    // language settings
    case choosePrimaryLanguageTappedFromLanguageSettings
    case chooseParallelLanguageTappedFromLanguageSettings
    case languageTappedFromChooseLanguage
    case deleteLanguageTappedFromChooseLanguage
    
    // article
    case backTappedFromArticleCategories
    case articleCategoryTappedFromArticleCategories(resource: ResourceModel, translationZipFile: TranslationZipFileModel, category: ArticleCategory, articleManifest: ArticleManifestXmlParser, currentArticleDownloadReceipt: ArticleManifestDownloadArticlesReceipt?)
    case articleTappedFromArticles(resource: ResourceModel, aemCacheObject: ArticleAemCacheObject)
    case sharedTappedFromArticle(articleAemData: ArticleAemData)
    case articleFlowCompleted(state: ArticleFlowCompletedState)
    
    // article deep link
    case didDownloadArticleFromLoadingArticle(aemCacheObject: ArticleAemCacheObject)
    case didFailToDownloadArticleFromLoadingArticle(alertMessage: AlertMessageType)
    
    // choose your own adventure
    case backTappedFromChooseYourOwnAdventure
    case chooseYourOwnAdventureFlowCompleted(state: ChooseYourOwnAdventureFlowCompletedState)
}
