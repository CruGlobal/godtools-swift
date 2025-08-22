//
//  CoreDataLayerDependenciesInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import LocalizationServices
import RequestOperation

protocol CoreDataLayerDependenciesInterface {
    
    func getAnalytics() -> AnalyticsContainer
    func getAppBuild() -> AppBuild
    func getAppConfig() -> AppConfig
    func getAppMessaging() -> AppMessagingInterface
    func getArticleAemRepository() -> ArticleAemRepository
    func getArticleManifestAemRepository() -> ArticleManifestAemRepository
    func getAttachmentsRepository() -> AttachmentsRepository
    func getCompletedTrainingTipRepository() -> CompletedTrainingTipRepository
    func getDeepLinkingService() -> DeepLinkingService
    func getDeviceSystemLanguage() -> DeviceSystemLanguageInterface
    func getEmailSignUpService() -> EmailSignUpService
    func getFavoritedResourcesRepository() -> FavoritedResourcesRepository
    func getFavoritingToolMessageCache() -> FavoritingToolMessageCache
    func getFirebaseConfiguration() -> FirebaseConfigurationInterface
    func getFirebaseDebugArguments() -> FirebaseDebugArgumentsInterface
    func getFollowUpsService() -> FollowUpsService
    func getInfoPlist() -> InfoPlist
    func getLanguagesRepository() -> LanguagesRepository
    func getLaunchCountRepository() -> LaunchCountRepositoryInterface
    func getLessonListItemProgressRepository() -> GetLessonListItemProgressRepository
    func getLocalizationLanguageNameRepository() -> LocalizationLanguageNameRepository
    func getLocalizationServices() -> LocalizationServicesInterface
    func getMobileContentAuthTokenKeychainAccessor() -> MobileContentAuthTokenKeychainAccessor
    func getMobileContentAuthTokenRepository() -> MobileContentAuthTokenRepository
    func getMobileContentApiAuthSession() -> MobileContentApiAuthSession
    func getOptInOnboardingBannerEnabledRepository() -> OptInOnboardingBannerEnabledRepository
    func getRemoteConfigRepository() -> RemoteConfigRepository
    func getRequestSender() -> RequestSender
    func getResourcesFileCache() -> ResourcesSHA256FileCache
    func getResourcesRepository() -> ResourcesRepository
    func getResourceViewsService() -> ResourceViewsService
    func getSearchBarInterfaceStringsRepositoryInterface() -> GetSearchBarInterfaceStringsRepositoryInterface
    func getSharedFirebaseMessaging() -> FirebaseMessaging
    func getSharedUrlSessionPriority() -> URLSessionPriority
    func getSharedRealmDatabase() -> RealmDatabase
    func getStringWithLocaleCount() -> StringWithLocaleCountInterface
    func getToolDownloader() -> ToolDownloader
    func getToolListItemInterfaceStringsRepository() -> GetToolListItemInterfaceStringsRepository
    func getTrackDownloadedTranslationsRepository() -> TrackDownloadedTranslationsRepository
    func getTranslatedLanguageName() -> GetTranslatedLanguageName
    func getTranslatedNumberCount() -> GetTranslatedNumberCount
    func getTranslatedPercentage() -> GetTranslatedPercentage
    func getTranslatedToolCategory() -> GetTranslatedToolCategory
    func getTranslatedToolLanguageAvailability() -> GetTranslatedToolLanguageAvailability
    func getTranslatedToolName() -> GetTranslatedToolName
    func getTranslationsRepository() -> TranslationsRepository
    func getTutorialVideoAnalytics() -> TutorialVideoAnalytics
    func getUserAuthentication() -> UserAuthentication
    func getUserCountersRepository() -> UserCountersRepository
    func getUserDefaultsCache() -> UserDefaultsCacheInterface
    func getUserLessonFiltersRepository() -> UserLessonFiltersRepository
    func getUserLessonProgressRepository() -> UserLessonProgressRepository
    func getWebSocket(url: URL) -> WebSocketInterface
}
