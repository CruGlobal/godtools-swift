//
//  MockDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import LocalizationServices
import RequestOperation

class MockDataLayerDependencies: CoreDataLayerDependenciesInterface {
    
    private let sharedUserDefaults: MockSharedUserDefaultsCache = MockSharedUserDefaultsCache()
    private let coreDataLayer: AppDataLayerDependencies // NOTE: For now I don't want to create interfaces for all the RealmDatabase repositories. However, that may slowly be worked in and this can be removed. ~Levi
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    func getAnalytics() -> AnalyticsContainer {
        return coreDataLayer.getAnalytics()
    }
    
    func getAppBuild() -> AppBuild {
        return coreDataLayer.getAppBuild()
    }
    
    func getAppConfig() -> AppConfig {
        return coreDataLayer.getAppConfig()
    }
    
    func getAppMessaging() -> AppMessagingInterface {
        return DisabledInAppMessaging()
    }
    
    func getArticleAemRepository() -> ArticleAemRepository {
        return coreDataLayer.getArticleAemRepository()
    }
    
    func getArticleManifestAemRepository() -> ArticleManifestAemRepository {
        return coreDataLayer.getArticleManifestAemRepository()
    }
    
    func getAttachmentsRepository() -> AttachmentsRepository {
        return coreDataLayer.getAttachmentsRepository()
    }
    
    func getCompletedTrainingTipRepository() -> CompletedTrainingTipRepository {
        return coreDataLayer.getCompletedTrainingTipRepository()
    }
    
    func getDeepLinkingService() -> DeepLinkingService {
        return coreDataLayer.getDeepLinkingService()
    }
    
    func getDeviceSystemLanguage() -> DeviceSystemLanguageInterface {
        return coreDataLayer.getDeviceSystemLanguage()
    }
    
    func getEmailSignUpService() -> EmailSignUpService {
        return coreDataLayer.getEmailSignUpService()
    }

    func getFavoritedResourcesRepository() -> FavoritedResourcesRepository {
        return coreDataLayer.getFavoritedResourcesRepository()
    }
    
    func getFavoritingToolMessageCache() -> FavoritingToolMessageCache {
        return coreDataLayer.getFavoritingToolMessageCache()
    }
    
    func getFirebaseConfiguration() -> FirebaseConfigurationInterface {
        return DisabledFirebaseConfiguration()
    }
    
    func getFirebaseDebugArguments() -> FirebaseDebugArgumentsInterface {
        return NoFirebaseDebugArguments()
    }
    
    func getFollowUpsService() -> FollowUpsService {
        return coreDataLayer.getFollowUpsService()
    }
    
    func getInfoPlist() -> InfoPlist {
        return coreDataLayer.getInfoPlist()
    }
    
    func getLanguagesRepository() -> LanguagesRepository {
        return coreDataLayer.getLanguagesRepository()
    }
    
    func getLaunchCountRepository() -> LaunchCountRepositoryInterface {
        return MockLaunchCountRepository(launchCount: 0)
    }
    
    func getLessonListItemProgressRepository() -> GetLessonListItemProgressRepository {
        return coreDataLayer.getLessonListItemProgressRepository()
    }
    
    func getLocalizationLanguageNameRepository() -> LocalizationLanguageNameRepository {
        return coreDataLayer.getLocalizationLanguageNameRepository()
    }
    
    func getLocalizationServices() -> LocalizationServicesInterface {
        return MockLocalizationServices(localizableStrings: [:])
    }
    
    func getMobileContentAuthTokenKeychainAccessor() -> MobileContentAuthTokenKeychainAccessor {
        return coreDataLayer.getMobileContentAuthTokenKeychainAccessor()
    }
    
    func getMobileContentAuthTokenRepository() -> MobileContentAuthTokenRepository {
        return coreDataLayer.getMobileContentAuthTokenRepository()
    }
    
    func getMobileContentApiAuthSession() -> MobileContentApiAuthSession {
        return coreDataLayer.getMobileContentApiAuthSession()
    }
    
    func getOptInOnboardingBannerEnabledRepository() -> OptInOnboardingBannerEnabledRepository {
        return coreDataLayer.getOptInOnboardingBannerEnabledRepository()
    }
    
    func getRemoteConfigRepository() -> RemoteConfigRepository {
        return RemoteConfigRepository(
            remoteDatabase: DisabledRemoteConfigDatabase()
        )
    }
    
    func getRequestSender() -> RequestSender {
        return DoesNotSendUrlRequestSender()
    }
    
    func getResourcesFileCache() -> ResourcesSHA256FileCache {
        return coreDataLayer.getResourcesFileCache()
    }
    
    func getResourcesRepository() -> ResourcesRepository {
        return coreDataLayer.getResourcesRepository()
    }
    
    func getResourceViewsService() -> ResourceViewsService {
        return coreDataLayer.getResourceViewsService()
    }
    
    func getSearchBarInterfaceStringsRepositoryInterface() -> GetSearchBarInterfaceStringsRepositoryInterface {
        return coreDataLayer.getSearchBarInterfaceStringsRepositoryInterface()
    }
    
    func getSharedFirebaseMessaging() -> FirebaseMessaging {
        return coreDataLayer.getSharedFirebaseMessaging()
    }
    
    func getSharedUrlSessionPriority() -> URLSessionPriority {
        return coreDataLayer.getSharedUrlSessionPriority()
    }
    
    func getSharedRealmDatabase() -> RealmDatabase {
        return coreDataLayer.getSharedRealmDatabase()
    }
    
    func getStringWithLocaleCount() -> StringWithLocaleCountInterface {
        return coreDataLayer.getStringWithLocaleCount()
    }
    
    func getToolDownloader() -> ToolDownloader {
        return coreDataLayer.getToolDownloader()
    }
    
    func getToolListItemInterfaceStringsRepository() -> GetToolListItemInterfaceStringsRepository {
        return coreDataLayer.getToolListItemInterfaceStringsRepository()
    }
    
    func getTrackDownloadedTranslationsRepository() -> TrackDownloadedTranslationsRepository {
        return coreDataLayer.getTrackDownloadedTranslationsRepository()
    }
    func getTranslatedLanguageName() -> GetTranslatedLanguageName {
        return coreDataLayer.getTranslatedLanguageName()
    }
    func getTranslatedNumberCount() -> GetTranslatedNumberCount {
        return coreDataLayer.getTranslatedNumberCount()
    }
    func getTranslatedPercentage() -> GetTranslatedPercentage {
        return coreDataLayer.getTranslatedPercentage()
    }
    
    func getTranslatedToolCategory() -> GetTranslatedToolCategory {
        return coreDataLayer.getTranslatedToolCategory()
    }
    
    func getTranslatedToolLanguageAvailability() -> GetTranslatedToolLanguageAvailability {
        return coreDataLayer.getTranslatedToolLanguageAvailability()
    }
    
    func getTranslatedToolName() -> GetTranslatedToolName {
        return coreDataLayer.getTranslatedToolName()
    }
    
    func getTranslationsRepository() -> TranslationsRepository {
        return coreDataLayer.getTranslationsRepository()
    }
    
    func getTutorialVideoAnalytics() -> TutorialVideoAnalytics {
        return coreDataLayer.getTutorialVideoAnalytics()
    }
    
    func getUserAuthentication() -> UserAuthentication {
        return coreDataLayer.getUserAuthentication()
    }
    
    func getUserCountersRepository() -> UserCountersRepository {
        return coreDataLayer.getUserCountersRepository()
    }

    func getUserDefaultsCache() -> UserDefaultsCacheInterface {
        return sharedUserDefaults
    }
    
    func getUserLessonFiltersRepository() -> UserLessonFiltersRepository {
        return coreDataLayer.getUserLessonFiltersRepository()
    }
    
    func getUserLessonProgressRepository() -> UserLessonProgressRepository {
        return coreDataLayer.getUserLessonProgressRepository()
    }
    
    func getWebSocket(url: URL) -> WebSocketInterface {
        return MockWebSocket(url: url)
    }
}
