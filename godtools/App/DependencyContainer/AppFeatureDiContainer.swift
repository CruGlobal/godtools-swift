//
//  AppFeatureDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class AppFeatureDiContainer {
    
    let account: AccountDiContainer
    let appLanguage: AppLanguageDiContainer
    let articles: ArticlesDiContainer
    let dashboard: DashboardDiContainer
    let deferredDeepLink: DeferredDeepLinkDiContainer
    let downloadToolProgress: DownloadToolProgressDiContainer
    let favorites: FavoritesDiContainer
    let featuredLessons: FeaturedLessonsDiContainer
    let globalActivity: GlobalActivityDiContainer
    let learnToShareTool: LearnToShareToolDiContainer
    let lessonEvaluation: LessonEvaluationDiContainer
    let lessonFilter: LessonFilterDiContainer
    let lessons: LessonsDiContainer
    let lessonProgress: UserLessonProgressDiContainer
    let lessonSwipeTutorial: LessonSwipeTutorialDiContainer
    let menu: MenuDiContainer
    let onboarding: OnboardingDiContainer
    let optInNotification: OptInNotificationDiContainer
    let persistToolLanguageSettingsForFavoritedTool: PersistToolLanguageSettingsForFavoritedToolDiContainer
    let personalizedTools: PersonalizedToolsDiContainer
    let shareables: ShareablesDiContainer
    let shareGodTools: ShareGodToolsDiContainer
    let shareTool: ShareToolDiContainer
    let spotlightTools: SpotlightToolsDiContainer
    let toolDetails: ToolDetailsDiContainer
    let tools: ToolsDiContainer
    let toolScreenShare: ToolScreenShareDiContainer
    let toolScreenShareQRCode: ToolScreenShareQRCodeDiContainer
    let toolSettings: ToolSettingsDiContainer
    let toolsFilter: ToolsFilterDiContainer
    let toolShortcutLinks: ToolShortcutLinksDiContainer
    let tutorial: TutorialDiContainer
    let userActivity: UserActivityDiContainer
    
    init(
        account: AccountDiContainer,
        appLanguage: AppLanguageDiContainer,
        articles: ArticlesDiContainer,
        dashboard: DashboardDiContainer,
        deferredDeepLink: DeferredDeepLinkDiContainer,
        downloadToolProgress: DownloadToolProgressDiContainer,
        favorites: FavoritesDiContainer,
        featuredLessons: FeaturedLessonsDiContainer,
        globalActivity: GlobalActivityDiContainer,
        learnToShareTool: LearnToShareToolDiContainer,
        lessonEvaluation: LessonEvaluationDiContainer,
        lessonFilter: LessonFilterDiContainer,
        lessons: LessonsDiContainer,
        lessonProgress: UserLessonProgressDiContainer,
        lessonSwipeTutorial: LessonSwipeTutorialDiContainer,
        menu: MenuDiContainer,
        onboarding: OnboardingDiContainer,
        optInNotification: OptInNotificationDiContainer,
        persistToolLanguageSettingsForFavoritedTool: PersistToolLanguageSettingsForFavoritedToolDiContainer,
        personalizedTools: PersonalizedToolsDiContainer,
        shareables: ShareablesDiContainer,
        shareGodTools: ShareGodToolsDiContainer,
        shareTool: ShareToolDiContainer,
        spotlightTools: SpotlightToolsDiContainer,
        toolDetails: ToolDetailsDiContainer,
        tools: ToolsDiContainer,
        toolScreenShare: ToolScreenShareDiContainer,
        toolScreenShareQRCode: ToolScreenShareQRCodeDiContainer,
        toolSettings: ToolSettingsDiContainer,
        toolsFilter: ToolsFilterDiContainer,
        toolShortcutLinks: ToolShortcutLinksDiContainer,
        tutorial: TutorialDiContainer,
        userActivity: UserActivityDiContainer
    ) {
        
        self.account = account
        self.appLanguage = appLanguage
        self.articles = articles
        self.dashboard = dashboard
        self.deferredDeepLink = deferredDeepLink
        self.downloadToolProgress = downloadToolProgress
        self.favorites = favorites
        self.featuredLessons = featuredLessons
        self.globalActivity = globalActivity
        self.learnToShareTool = learnToShareTool
        self.lessonEvaluation = lessonEvaluation
        self.lessonFilter = lessonFilter
        self.lessons = lessons
        self.lessonProgress = lessonProgress
        self.lessonSwipeTutorial = lessonSwipeTutorial
        self.menu = menu
        self.onboarding = onboarding
        self.optInNotification = optInNotification
        self.persistToolLanguageSettingsForFavoritedTool = persistToolLanguageSettingsForFavoritedTool
        self.personalizedTools = personalizedTools
        self.shareables = shareables
        self.shareGodTools = shareGodTools
        self.shareTool = shareTool
        self.spotlightTools = spotlightTools
        self.toolDetails = toolDetails
        self.tools = tools
        self.toolScreenShare = toolScreenShare
        self.toolScreenShareQRCode = toolScreenShareQRCode
        self.toolSettings = toolSettings
        self.toolsFilter = toolsFilter
        self.toolShortcutLinks = toolShortcutLinks
        self.tutorial = tutorial
        self.userActivity = userActivity
    }
}
