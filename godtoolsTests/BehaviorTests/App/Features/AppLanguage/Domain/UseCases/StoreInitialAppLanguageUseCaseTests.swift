//
//  StoreInitialAppLanguageUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import Combine
import RepositorySync

@Suite(.serialized)
struct StoreInitialAppLanguageUseCaseTests {
    
    struct TestArgument {
    
        let appLanguage: LanguageCodeDomainModel?
        let deviceLanguage: LanguageCodeDomainModel
        let expectedValue: String
    }
    
    @Test(
        """
        Given: App is launched.
        When: No app language is currently set and my device language is a supported app language.
        Then: I expect my app language to be my device language since my device language is a supported app language.
        """,
        arguments: [
            TestArgument(
                appLanguage: nil,
                deviceLanguage: .english,
                expectedValue: LanguageCodeDomainModel.english.rawValue
            ),
            TestArgument(
                appLanguage: nil,
                deviceLanguage: .arabic,
                expectedValue: LanguageCodeDomainModel.arabic.rawValue
            )
        ]
    )
    @MainActor func noAppLanguageSetDefaultsToDeviceLanguageWhenSupported(argument: TestArgument) async throws {
        
        let testsDiContainer = try getTestsDiContainer()
        
        let realmDatabase: RealmDatabase = testsDiContainer.core.dataLayer.getSharedRealmDatabase()
                
        let appLanguages: [AppLanguageCodable] = [
            AppLanguageCodable(languageCode: "ar", languageDirection: .rightToLeft, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "en", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "es", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hans"),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hant"),
            AppLanguageCodable(languageCode: "lv", languageDirection: .leftToRight, languageScriptCode: nil)
        ]
        
        let mockAppLanguagesSync: AppLanguagesRepositorySyncInterface = try MockAppLanguagesRepositorySync(
            realmDatabase: realmDatabase,
            appLanguages: appLanguages
        )
        
        let userAppLanguageRepository = getUserAppLanguageRepository(testsDiContainer: testsDiContainer)
        
        try await userAppLanguageRepository.deleteLanguage()
                        
        let appLanguagesRepository: AppLanguagesRepository = testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository(
            sync: mockAppLanguagesSync
        )
        
        let storeInitialAppLanguage = StoreInitialAppLanguageUseCase(
            deviceSystemLanguage: MockDeviceSystemLanguage(deviceLocale: Locale(identifier: argument.deviceLanguage.rawValue)),
            userAppLanguageRepository: userAppLanguageRepository,
            appLanguagesRepository: appLanguagesRepository
        )
        
        var resultRef: AppLanguageDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            storeInitialAppLanguage
                .execute()
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (result: AppLanguageDomainModel) in
                    
                    resultRef = result
                                     
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }
        
        #expect(resultRef == argument.expectedValue)
    }
    
    @Test(
        """
        Given: App is launched.
        When: App language is set and is a supported app language.
        Then: I expect to see my app language.
        """,
        arguments: [
            TestArgument(
                appLanguage: .english,
                deviceLanguage: .arabic,
                expectedValue: LanguageCodeDomainModel.english.rawValue
            ),
            TestArgument(
                appLanguage: .spanish,
                deviceLanguage: .arabic,
                expectedValue: LanguageCodeDomainModel.spanish.rawValue
            )
        ]
    )
    @MainActor func appLanguageSetAndSupportedShowsMyAppLanguage(argument: TestArgument) async throws {
        
        let testsDiContainer = try getTestsDiContainer()
        
        let realmDatabase: RealmDatabase = testsDiContainer.core.dataLayer.getSharedRealmDatabase()
        
        let appLanguages: [AppLanguageCodable] = [
            AppLanguageCodable(languageCode: "ar", languageDirection: .rightToLeft, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "en", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "es", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hans"),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hant"),
            AppLanguageCodable(languageCode: "lv", languageDirection: .leftToRight, languageScriptCode: nil)
        ]
        
        let mockAppLanguagesSync: AppLanguagesRepositorySyncInterface = try MockAppLanguagesRepositorySync(
            realmDatabase: realmDatabase,
            appLanguages: appLanguages
        )
        
        let userAppLanguageRepository = getUserAppLanguageRepository(testsDiContainer: testsDiContainer)
                                
        let appLanguagesRepository: AppLanguagesRepository = testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository(
            sync: mockAppLanguagesSync
        )
        
        let storeInitialAppLanguage = StoreInitialAppLanguageUseCase(
            deviceSystemLanguage: MockDeviceSystemLanguage(deviceLocale: Locale(identifier: argument.deviceLanguage.rawValue)),
            userAppLanguageRepository: userAppLanguageRepository,
            appLanguagesRepository: appLanguagesRepository
        )
        
        let storeAppLanguage: String = try #require(argument.appLanguage?.rawValue)
        
        try await userAppLanguageRepository
            .storeLanguage(appLanguageId: storeAppLanguage)
        
        var resultRef: AppLanguageDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            storeInitialAppLanguage
                .execute()
                .sink { _ in
                    
                } receiveValue: { (appLanguage: BCP47LanguageIdentifier) in
                    
                    resultRef = appLanguage
                    
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                }
                .store(in: &cancellables)
        }
                
        #expect(resultRef == argument.expectedValue)
    }
    
    @Test(
        """
        Given: App is launched.
        When: No app language is currently set and my device language is not a supported app language.
        Then: I expect my app language to be english since my device language is not a supported app language..
        """,
        arguments: [
            TestArgument(
                appLanguage: nil,
                deviceLanguage: .czech,
                expectedValue: LanguageCodeDomainModel.english.rawValue
            )
        ]
    )
    @MainActor func noAppLanguageSetAndDeviceLanguageIsNotASupportedAppLanguage(argument: TestArgument) async throws {
        
        let testsDiContainer = try getTestsDiContainer()
        
        let realmDatabase: RealmDatabase = testsDiContainer.core.dataLayer.getSharedRealmDatabase()
        
        let appLanguages: [AppLanguageCodable] = [
            AppLanguageCodable(languageCode: "ar", languageDirection: .rightToLeft, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "en", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "es", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hans"),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hant"),
            AppLanguageCodable(languageCode: "lv", languageDirection: .leftToRight, languageScriptCode: nil)
        ]
        
        let mockAppLanguagesSync: AppLanguagesRepositorySyncInterface = try MockAppLanguagesRepositorySync(
            realmDatabase: realmDatabase,
            appLanguages: appLanguages
        )
        
        let userAppLanguageRepository = getUserAppLanguageRepository(testsDiContainer: testsDiContainer)
        
        try await userAppLanguageRepository.deleteLanguage()
                                
        let appLanguagesRepository: AppLanguagesRepository = testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository(
            sync: mockAppLanguagesSync
        )
        
        let storeInitialAppLanguage = StoreInitialAppLanguageUseCase(
            deviceSystemLanguage: MockDeviceSystemLanguage(deviceLocale: Locale(identifier: argument.deviceLanguage.rawValue)),
            userAppLanguageRepository: userAppLanguageRepository,
            appLanguagesRepository: appLanguagesRepository
        )
        
        var resultRef: AppLanguageDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            storeInitialAppLanguage
                .execute()
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (result: AppLanguageDomainModel) in
                    
                    resultRef = result
                                       
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }
        
        #expect(resultRef == argument.expectedValue)
    }
}

extension StoreInitialAppLanguageUseCaseTests {
    
    private func getTestsDiContainer(addRealmObjects: [IdentifiableRealmObject] = Array()) throws -> TestsDiContainer {
                
        return try TestsDiContainer(
            realmFileName: String(describing: StoreInitialAppLanguageUseCaseTests.self),
            addRealmObjects: addRealmObjects
        )
    }
    
    private func getUserAppLanguageRepository(testsDiContainer: TestsDiContainer) -> UserAppLanguageRepository {
        
        let persistence = RealmRepositorySyncPersistence(
            database: testsDiContainer.core.dataLayer.getSharedRealmDatabase(),
            mapping: RealmUserAppLanguageMapping()
        )
        
        let cache = UserAppLanguageCache(
            persistence: persistence
        )
        
        return UserAppLanguageRepository(cache: cache)
    }
}
