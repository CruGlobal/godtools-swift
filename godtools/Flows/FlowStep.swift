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
    case urlLinkTappedFromToolDetail(url: URL)
    
    // tools
    case menuTappedFromTools
    case languageSettingsTappedFromTools
    
    // onboarding
    case beginTappedFromOnboardingWelcome
    case skipTappedFromOnboardingTutorial
    case showMoreTappedFromOnboardingTutorial
    case getStartedTappedFromOnboardingTutorial
    
    // home
    case openTutorialTapped
    
    // myTools
    case toolTappedFromMyTools(resource: DownloadedResource)
    case toolInfoTappedFromMyTools(resource: DownloadedResource)
    
    // findTools
    case toolTappedFromFindTools(resource: DownloadedResource)
    case toolInfoTappedFromFindTools(resource: DownloadedResource)
    
    // toolDetails
    case openToolTappedFromToolDetails(resource: DownloadedResource)
    
    // tract
    case homeTappedFromTract
    case shareTappedFromTract(resource: DownloadedResource, language: Language, pageNumber: Int)
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
    
    // articles
    case articleCategoryTappedFromArticleCategories(resource: DownloadedResource, godToolsResource: GodToolsResource, category: ArticleCategory)
    case articleTappedFromArticles(resource: DownloadedResource, godToolsResource: GodToolsResource, articleAemImportData: RealmArticleAemImportData)
    case sharedTappedFromArticle(articleAemImportData: RealmArticleAemImportData)
}
