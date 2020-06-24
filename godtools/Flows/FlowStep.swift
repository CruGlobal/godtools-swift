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
    case urlLinkTappedFromToolDetail(url: URL)
        
    // tract
    case homeTappedFromTract
    case shareTappedFromTract(resource: ResourceModel, language: LanguageModel, pageNumber: Int)
    case sendEmailTappedFromTract(subject: String, message: String, isHtml: Bool)
    
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
    
    // articles
    case articleCategoryTappedFromArticleCategories(resource: ResourceModel, translationManifest: TranslationManifest, category: ArticleCategory, articleManifest: ArticleManifestXmlParser)
    case articleTappedFromArticles(resource: ResourceModel, translationManifest: TranslationManifest, articleAemImportData: ArticleAemImportData)
    case sharedTappedFromArticle(articleAemImportData: ArticleAemImportData)
}
