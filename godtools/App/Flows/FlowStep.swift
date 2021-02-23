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
    case showTools(animated: Bool, shouldCreateNewInstance: Bool)
    case showMenu
    case showLanguageSettings
    case showOnboardingTutorial(animated: Bool)
    case dismissOnboardingTutorial
    
    // tools
    case menuTappedFromTools
    case languageSettingsTappedFromTools
    case openTutorialTapped
    
    // onboarding
    case beginTappedFromOnboardingWelcome
    case skipTappedFromOnboardingTutorial
    case showMoreTappedFromOnboardingTutorial
    case getStartedTappedFromOnboardingTutorial
    
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
    case urlLinkTappedFromToolDetail(url: URL)
    
    // learnToShareTool
    case closeTappedFromLearnToShareTool(resource: ResourceModel)
    case continueTappedFromLearnToShareTool(resource: ResourceModel)
        
    // tool
    case homeTappedFromTool(isScreenSharing: Bool)
    case shareMenuTappedFromTool(tractRemoteShareSubscriber: TractRemoteShareSubscriber, tractRemoteSharePublisher: TractRemoteSharePublisher, resource: ResourceModel, selectedLanguage: LanguageModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, pageNumber: Int)
    case urlLinkTappedFromTool(url: URL)
    case toolDidEncounterErrorFromTool(error: ContentEventError)
    case toolTrainingTipTappedFromTool(resource: ResourceModel, manifest: MobileContentXmlManifest, trainingTipId: String, tipNode: TipNode, language: LanguageModel, primaryLanguage: LanguageModel, toolPage: Int)
    
    // tool training
    case closeTappedFromToolTraining
    case urlLinkTappedFromToolTraining(url: URL)
    
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
    case logoutTappedFromMenu(logoutHandler: CallbackHandler)
    case playgroundTappedFromMenu
    
    // language settings
    case choosePrimaryLanguageTappedFromLanguageSettings
    case chooseParallelLanguageTappedFromLanguageSettings
    case languageTappedFromChooseLanguage
    case deleteLanguageTappedFromChooseLanguage
    
    // articles
    case articleCategoryTappedFromArticleCategories(resource: ResourceModel, translationZipFile: TranslationZipFileModel, category: ArticleCategory, articleManifest: ArticleManifestXmlParser)
    case articleTappedFromArticles(resource: ResourceModel, translationZipFile: TranslationZipFileModel, articleAemImportData: ArticleAemImportData)
    case articleDeepLinkTapped(articleUri: URL)
    case sharedTappedFromArticle(articleAemImportData: ArticleAemImportData)
}
