//
//  AppDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import SocialAuthentication
import LocalizationServices
import RepositorySync

final class AppDataLayerDependencies {
        
    private let sharedAppConfig: AppConfigInterface
    private let sharedUrlSessionPriority: URLSessionPriority = URLSessionPriority()
    private let sharedAnalytics: AnalyticsContainer
    private let sharedInMemoryDataCache: InMemoryDataCache = InMemoryDataCache()
    private let sharedRealmDatabaseConfig: RealmDatabaseConfig
    private let sharedRealmDatabase: RealmDatabase
    
    private lazy var sharedUserCountersSync: UserCountersSync = {
        
        let syncInvalidator = SyncInvalidator(
            id:  "UserCountersSync.sync",
            timeInterval: .hours(hour: 2),
            persistence: getUserDefaultsCache()
        )
        
        return UserCountersSync(
            api: getUserCountersApi(),
            cache: getUserCountersCache(),
            localActivityCounterCache: getLocalActivityCounterCache(),
            syncInvalidator: syncInvalidator
        )
    }()
    
    init(appConfig: AppConfigInterface) {
        
        sharedAppConfig = appConfig
        
        sharedAnalytics = AnalyticsContainer(
            firebaseAnalytics: Self.getFirebaseAnalytics(appConfig: appConfig)
        )
        
        do {
            sharedRealmDatabaseConfig = try appConfig.getRealmDatabaseConfig()
        }
        catch let error {
            assertionFailure(error.localizedDescription)
            sharedRealmDatabaseConfig = try! RealmDatabaseConfig.createInMemoryConfig()
        }
        
        sharedRealmDatabase = RealmDatabase(databaseConfig: sharedRealmDatabaseConfig)
    }
    
    private static func getFirebaseAnalytics(appConfig: AppConfigInterface) -> FirebaseAnalyticsInterface {
        
        let firebaseAnalyticsEnabled: Bool = appConfig.analyticsEnabled && appConfig.firebaseEnabled
        
        guard firebaseAnalyticsEnabled else {
            return DisabledFirebaseAnalytics()
        }
        
        return FirebaseAnalytics(
            isDebug: appConfig.isDebug,
            loggingEnabled: appConfig.buildConfig == .analyticsLogging
        )
    }
    
    // MARK: - Data Layer Classes
    
    func getAnalytics() -> AnalyticsContainer {
        return sharedAnalytics
    }
    
    func getAppConfig() -> AppConfigInterface {
        return sharedAppConfig
    }
    
    func getAppMessaging() -> AppMessagingInterface {
        return sharedAppConfig.firebaseEnabled ? FirebaseInAppMessaging.shared : DisabledInAppMessaging()
    }
    
    private func getArticleAemCache() -> ArticleAemCache {
        
        let persistence: any Persistence<ArticleAemData, ArticleAemData>
        
        if #available(iOS 17.4, *), let database = getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftArticleAemDataMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                databaseConfig: getSharedRealmDatabaseConfig(),
                mapping: RealmArticleAemDataMapping()
            )
        }
        
        return ArticleAemCache(
            persistence: persistence,
            articleWebArchiver: ArticleWebArchiver(
                urlSessionPriority: getSharedUrlSessionPriority(),
                requestSender: getRequestSender()
            )
        )
    }
    
    private func getArticleAemDownloader() -> ArticleAemDownloader {
        return ArticleAemDownloader(
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getRequestSender()
        )
    }
    
    func getArticleAemRepository() -> ArticleAemRepository {
        return ArticleAemRepository(
            downloader: getArticleAemDownloader(),
            cache: getArticleAemCache()
        )
    }
    
    func getArticleManifestAemRepository() -> ArticleManifestAemRepository {
        
        let persistence: any Persistence<CategoryArticleModel, CategoryArticleModel>
        
        if #available(iOS 17.4, *), let database = getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftCategoryArticleMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                databaseConfig: getSharedRealmDatabaseConfig(),
                mapping: RealmCategoryArticleMapping()
            )
        }
        
        return ArticleManifestAemRepository(
            downloader: getArticleAemDownloader(),
            cache: getArticleAemCache(),
            categoryArticlesCache: CategoryArticlesCache(
                persistence: persistence
            ),
            syncInvalidatorPersistence: getUserDefaultsCache()
        )
    }
    
    func getAttachmentsRepository() -> AttachmentsRepository {
                
        let persistence: any Persistence<AttachmentDataModel, AttachmentCodable>
        
        if #available(iOS 17.4, *), let database = getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftAttachmentMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                databaseConfig: getSharedRealmDatabaseConfig(),
                mapping: RealmAttachmentMapping()
            )
        }
        
        let api = MobileContentAttachmentsApi(
            config: getAppConfig(),
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getRequestSender()
        )
        
        let cache = AttachmentsCache(
            persistence: persistence,
            resourcesFileCache: getResourcesFileCache(),
            bundle: AttachmentsBundleCache()
        )
        
        return AttachmentsRepository(
            api: api,
            cache: cache
        )
    }
    
    func getCardJumpService() -> CardJumpService {
        return CardJumpService(
            cardJumpCache: CardJumpUserDefaultsCache(userDefaultsCache: getUserDefaultsCache())
        )
    }
    
    func getCompletedTrainingTipRepository() -> CompletedTrainingTipRepository {
        
        let persistence: any Persistence<CompletedTrainingTipDataModel, CompletedTrainingTipDataModel>
        
        if #available(iOS 17.4, *), let database = getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftCompletedTrainingTipMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                databaseConfig: getSharedRealmDatabaseConfig(),
                mapping: RealmCompletedTrainingTipMapping()
            )
        }
        
        return CompletedTrainingTipRepository(
            cache: CompletedTrainingTipCache(
                persistence: persistence
            )
        )
    }
    
    func getDeepLinkingService() -> DeepLinkingService {
        return DeepLinkingService(
            manifest: GodToolsDeepLinkingManifest()
        )
    }
    
    func getDeviceSystemLanguage() -> DeviceSystemLanguageInterface {
        return DeviceSystemLanguage()
    }
    
    func getEmailSignUpService() -> EmailSignUpService {
        
        let persistence: any Persistence<EmailSignUpDataModel, EmailSignUpDataModel>
        
        if #available(iOS 17.4, *), let database = getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftEmailSignUpMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                databaseConfig: getSharedRealmDatabaseConfig(),
                mapping: RealmEmailSignUpMapping()
            )
        }
        
        let api = EmailSignUpApi(
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getRequestSender()
        )
        
        return EmailSignUpService(
            api: api,
            cache: EmailSignUpsCache(persistence: persistence)
        )
    }
    
    func getErrorReporting() -> ErrorReportingInterface {
        return getFirebaseNonFatalErrorReporting()
    }
    
    func getFavoritedResourcesRepository() -> FavoritedResourcesRepository {
        
        let persistence: any Persistence<FavoritedResourceDataModel, FavoritedResourceDataModel>
        
        if #available(iOS 17.4, *), let database = getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftFavoritedResourceMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                databaseConfig: getSharedRealmDatabaseConfig(),
                mapping: RealmFavoritedResourceMapping()
            )
        }
        
        return FavoritedResourcesRepository(
            cache: FavoritedResourcesCache(persistence: persistence)
        )
    }
    
    func getFavoritingToolMessageCache() -> FavoritingToolMessageCache {
        return FavoritingToolMessageCache(userDefaultsCache: getUserDefaultsCache())
    }
    
    func getFirebaseConfiguration() -> FirebaseConfiguration {
        return FirebaseConfiguration(config: getAppConfig())
    }
    
    func getFirebaseDebugArguments() -> FirebaseDebugArguments {
        return FirebaseDebugArguments()
    }
    
    func getFirebaseNonFatalErrorReporting() -> FirebaseNonFatalErrorReporting {
        return FirebaseNonFatalErrorReporting()
    }
    
    func getFollowUpsService() -> FollowUpsService {
        
        let persistence: any Persistence<FollowUpDataModel, FollowUpDataModel>
        
        if #available(iOS 17.4, *), let database = getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftFollowUpMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                databaseConfig: getSharedRealmDatabaseConfig(),
                mapping: RealmFollowUpMapping()
            )
        }
        
        let api = FollowUpsApi(
            baseUrl: getAppConfig().getMobileContentApiBaseUrl(),
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getRequestSender()
        )
        
        let cache = FailedFollowUpsCache(
            persistence: persistence
        )
        
        return FollowUpsService(
            api: api,
            cache: cache
        )
    }
    
    func getInfoPlist() -> InfoPlist {
        return InfoPlist()
    }
    
    func getLanguagesRepository() -> LanguagesRepository {
                
        let persistence: any Persistence<LanguageDataModel, LanguageCodable>
        
        if #available(iOS 17.4, *), let database = getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftLanguageMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                databaseConfig: getSharedRealmDatabaseConfig(),
                mapping: RealmLanguageMapping()
            )
        }
        
        let api = MobileContentLanguagesApi(
            config: getAppConfig(),
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getRequestSender()
        )
        
        let cache = LanguagesCache(persistence: persistence)
                
        return LanguagesRepository(
            api: api,
            jsonFileCache: LanguagesJsonFileCache(jsonServices: JsonServices()),
            cache: cache
        )
    }
    
    func getLaunchCountRepository() -> LaunchCountRepositoryInterface {
        return LaunchCountRepository.shared
    }
    
    func getLocalizationServices() -> LocalizationServicesInterface {
        return LocalizationServices(
            localizableStringsFilesBundle: Bundle.main,
            isUsingBaseInternationalization: false
        )
    }
    
    func getMobileContentAuthTokenKeychainAccessor() -> MobileContentAuthTokenKeychainAccessor {
        return MobileContentAuthTokenKeychainAccessor()
    }
    
    func getMobileContentAuthTokenRepository() -> MobileContentAuthTokenRepository {
        
        let persistence: any Persistence<MobileContentAuthTokenDataModel, MobileContentAuthTokenDecodable>
        
        if #available(iOS 17.4, *), let database = getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftMobileContentAuthTokenMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                databaseConfig: getSharedRealmDatabaseConfig(),
                mapping: RealmMobileContentAuthTokenMapping()
            )
        }
        
        let api = MobileContentAuthTokenApi(
            config: getAppConfig(),
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getRequestSender()
        )
        
        let cache = MobileContentAuthTokenCache(
            mobileContentAuthTokenKeychainAccessor: getMobileContentAuthTokenKeychainAccessor(),
            persistence: persistence
        )
        
        return MobileContentAuthTokenRepository(
            api: api,
            cache: cache
        )
    }
    
    func getMobileContentApiAuthSession() -> MobileContentApiAuthSession {
        return MobileContentApiAuthSession(
            requestSender: getRequestSender(),
            mobileContentAuthTokenRepository: getMobileContentAuthTokenRepository(),
            userAuthentication: getUserAuthentication()
        )
    }
    
    func getMobileContentRendererManifestResourcesCache() -> MobileContentRendererManifestResourcesCache {
        return MobileContentRendererManifestResourcesCache(
            resourcesFileCache: getResourcesFileCache()
        )
    }
    
    func getRemoteConfigRepository() -> RemoteConfigRepository {
        return RemoteConfigRepository(
            remoteDatabase: sharedAppConfig.firebaseEnabled ? FirebaseRemoteConfigWrapper() : DisabledRemoteConfigDatabase()
        )
    }
    
    func getRequestSender() -> RequestSenderInterface {
        return sharedAppConfig.urlRequestsEnabled ? RequestSender() : DoesNotSendUrlRequestSender()
    }
    
    func getResourcesFileCache() -> ResourcesSHA256FileCache {
        return ResourcesSHA256FileCache(
            realmDatabase: getSharedRealmDatabase()
        )
    }
    
    func getResourcesRepository() -> ResourcesRepository {
                
        let persistence: any Persistence<ResourceDataModel, ResourceCodable>
        
        if #available(iOS 17.4, *), let database = getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftResourceMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                databaseConfig: getSharedRealmDatabaseConfig(),
                mapping: RealmResourceMapping()
            )
        }
        
        let api = MobileContentResourcesApi(
            config: getAppConfig(),
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getRequestSender()
        )
        
        let cache = ResourcesCache(
            persistence: persistence,
            trackDownloadedTranslationsRepository: getTrackDownloadedTranslationsRepository()
        )
        
        return ResourcesRepository(
            api: api,
            jsonFileCache: ResourcesJsonFileCache(jsonServices: JsonServices()),
            cache: cache,
            attachmentsRepository: getAttachmentsRepository(),
            languagesRepository: getLanguagesRepository(),
            syncInvalidatorPersistence: getUserDefaultsCache(),
            userDefaultsCache: getUserDefaultsCache()
        )
    }
    
    func getResourceViewsService() -> ResourceViewsService {
        
        return ResourceViewsService(
            api: MobileContentResourceViewsApi(
                config: getAppConfig(),
                urlSessionPriority: getSharedUrlSessionPriority(),
                requestSender: getRequestSender()
            ),
            failedResourceViewsCache: FailedResourceViewsCache(
                realmDatabase: getSharedRealmDatabase()
            )
        )
    }
    
    func getSharedFirebaseMessaging() -> FirebaseMessaging {
        return FirebaseMessaging.shared
    }
    
    func getSharedInMemoryDataCache() -> InMemoryDataCache {
        return sharedInMemoryDataCache
    }
    
    func getSharedUrlSessionPriority() -> URLSessionPriority {
        return sharedUrlSessionPriority
    }
    
    func getSharedRealmDatabaseConfig() -> RealmDatabaseConfig {
        return sharedRealmDatabaseConfig
    }
    
    func getSharedRealmDatabase() -> RealmDatabase {
        return sharedRealmDatabase
    }
    
    @available(iOS 17.4, *)
    func getSharedSwiftDatabase() -> SwiftDatabase? {
        do {
            return try getAppConfig().getSwiftDatabase()
        }
        catch _ {
            assertionFailure("Failed to get swift database.")
            return nil
        }
    }
    
    func getStringWithLocaleCount() -> StringWithLocaleCountInterface {
        return StringWithLocaleCount()
    }
    
    func getToolDownloader() -> ToolDownloader {
        return ToolDownloader(
            languagesRepository: getLanguagesRepository(),
            translationsRepository: getTranslationsRepository(),
            attachmentsRepository: getAttachmentsRepository(),
            articleManifestAemRepository: getArticleManifestAemRepository(),
            getToolDataToDownload: ToolDownloaderGetDataToDownload(
                resourcesRepository: getResourcesRepository(),
                attachmentsRepository: getAttachmentsRepository(),
                translationsRepository: getTranslationsRepository()
            )
        )
    }
    
    func getTrackDownloadedTranslationsRepository() -> TrackDownloadedTranslationsRepository {
                
        let persistence: any Persistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel>
        
        if #available(iOS 17.4, *), let database = getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftDownloadedTranslationMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                databaseConfig: getSharedRealmDatabaseConfig(),
                mapping: RealmDownloadedTranslationMapping()
            )
        }
        
        let cache = TrackDownloadedTranslationsCache(
            persistence: persistence
        )
        
        return TrackDownloadedTranslationsRepository(
            cache: cache
        )
    }
    
    func getTranslationsRepository() -> TranslationsRepository {
                
        let persistence: any Persistence<TranslationDataModel, TranslationCodable>
        
        if #available(iOS 17.4, *), let database = getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftTranslationMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                databaseConfig: getSharedRealmDatabaseConfig(),
                mapping: RealmTranslationMapping()
            )
        }
        
        let api = MobileContentTranslationsApi(
            config: getAppConfig(),
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getRequestSender()
        )
        
        let cdn = MobileContentTranslationsCdn(
            config: getAppConfig(),
            urlSessionPriority: getSharedUrlSessionPriority(),
            requestSender: getRequestSender()
        )
        
        let cache = TranslationsCache(persistence: persistence)
        
        return TranslationsRepository(
            api: api,
            cdn: cdn,
            cache: cache,
            infoPlist: getInfoPlist(),
            resourcesFileCache: getResourcesFileCache(),
            trackDownloadedTranslationsRepository: getTrackDownloadedTranslationsRepository(),
            remoteConfigRepository: getRemoteConfigRepository()
        )
    }
    
    func getTutorialVideoAnalytics() -> TutorialVideoAnalytics {
        return TutorialVideoAnalytics(
            trackActionAnalytics: getAnalytics().trackActionAnalytics
        )
    }
    
    func getUITestsInitialDataLoader() -> UITestsInitialDataLoader {
        return UITestsInitialDataLoader(
            realmDatabase: getSharedRealmDatabase(),
            resourcesFileCache: getResourcesFileCache()
        )
    }

    func getUserAuthentication() -> UserAuthentication {
                
        var authenticationProviders: [AuthenticationProviderType: AuthenticationProviderInterface] = Dictionary()
        
        authenticationProviders[.apple] = AppleAuthentication(
            appleUserPersistentStore: AppleUserPersistentStore()
        )
        
        authenticationProviders[.facebook] = FacebookLimitedLogin(
            configuration: FacebookLimitedLoginConfiguration(permissions: ["email"])
        )
        
        if let googleAuthConfiguration = getAppConfig().getGoogleAuthenticationConfiguration() {
            authenticationProviders[.google] = GoogleAuthentication(
                configuration: googleAuthConfiguration
            )
        }
        
        return UserAuthentication(
            authenticationProviders: authenticationProviders,
            lastAuthenticatedProviderCache: LastAuthenticatedProviderCache(userDefaultsCache: getUserDefaultsCache()),
            mobileContentAuthTokenRepository: getMobileContentAuthTokenRepository()
        )
    }
    
    func getUserDefaultsCache() -> UserDefaultsCacheInterface {
        return getAppConfig().getUserDefaultsCache()
    }
    
    func getUserLessonFiltersRepository() -> UserLessonFiltersRepository {
        
        let persistence: any Persistence<UserLessonLanguageFilterDataModel, UserLessonLanguageFilterDataModel>
        
        if #available(iOS 17.4, *), let database = getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftUserLessonLanguageFilterMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                databaseConfig: getSharedRealmDatabaseConfig(),
                mapping: RealmUserLessonLanguageFilterMapping()
            )
        }
        
        return UserLessonFiltersRepository(
            cache: UserLessonFiltersCache(
                persistence: persistence
            )
        )
    }
    
    func getUserLessonProgressRepository() -> UserLessonProgressRepository {
        
        let persistence: any Persistence<UserLessonProgressDataModel, UserLessonProgressDataModel>
        
        if #available(iOS 17.4, *), let database = getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftUserLessonProgressMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                databaseConfig: getSharedRealmDatabaseConfig(),
                mapping: RealmUserLessonProgressMapping()
            )
        }
        
        return UserLessonProgressRepository(
            cache: UserLessonProgressCache(
                persistence: persistence
            )
        )
    }
    
    func getWebSocket(url: URL) -> WebSocketInterface {
        return URLSessionWebSocket(url: url)
    }
}

// MARK: - User Counters

extension AppDataLayerDependencies {
    
    private func getLocalActivityCounterCache() -> LocalActivityCounterCache {
        
        let persistence: any Persistence<LocalActivityCountDataModel, LocalActivityCountDataModel>
        
        if #available(iOS 17.4, *), let database = getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftLocalActivityCountMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                databaseConfig: getSharedRealmDatabaseConfig(),
                mapping: RealmLocalActivityCountMapping()
            )
        }
        
        return LocalActivityCounterCache(persistence: persistence)
    }
    
    func getSharedUserCountersSync() -> UserCountersSync {
        return sharedUserCountersSync
    }
    
    private func getUserCountersApi() -> UserCountersApi {
        
        let api = UserCountersApi(
            config: getAppConfig(),
            urlSessionPriority: getSharedUrlSessionPriority(),
            mobileContentApiAuthSession: getMobileContentApiAuthSession()
        )
        
        return api
    }
    
    private func getUserCountersCache() -> UserCountersCache {
        
        let persistence: any Persistence<UserCounterDataModel, UserCounterCodable>
        
        if #available(iOS 17.4, *), let database = getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftUserCounterMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                databaseConfig: getSharedRealmDatabaseConfig(),
                mapping: RealmUserCounterMapping()
            )
        }
                
        return UserCountersCache(
            localActivityCounterCache: getLocalActivityCounterCache(),
            persistence: persistence
        )
    }
    
    func getUserCountersRepository() -> UserCountersRepository {
            
        return UserCountersRepository(
            localActivityCounterCache: getLocalActivityCounterCache(),
            cache: getUserCountersCache()
        )
    }
}
