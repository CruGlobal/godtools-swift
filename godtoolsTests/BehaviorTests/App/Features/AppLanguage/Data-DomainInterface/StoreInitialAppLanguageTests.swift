//
//  StoreInitialAppLanguageTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import Combine

struct StoreInitialAppLanguageTests {
    
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
    @MainActor func noAppLanguageSetDefaultsToDeviceLanguageWhenSupported(argument: TestArgument) async {
        
        let testsDiContainer = TestsDiContainer()
        
        let testsRealmDatabase: LegacyRealmDatabase = testsDiContainer.dataLayer.getSharedLegacyRealmDatabase()
        
        let appLanguages: [AppLanguageCodable] = [
            AppLanguageCodable(languageCode: "ar", languageDirection: .rightToLeft, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "en", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "es", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hans"),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hant"),
            AppLanguageCodable(languageCode: "lv", languageDirection: .leftToRight, languageScriptCode: nil)
        ]
        
        let mockAppLanguagesSync: AppLanguagesRepositorySyncInterface = MockAppLanguagesRepositorySync(
            realmDatabase: testsRealmDatabase,
            appLanguages: appLanguages
        )
        
        let userAppLanguageCache: RealmUserAppLanguageCache = RealmUserAppLanguageCache(
            realmDatabase: testsRealmDatabase
        )
        
        _ = userAppLanguageCache.deleteLanguage()
                        
        let appLanguagesRepository: AppLanguagesRepository = testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository(
            realmDatabase: testsRealmDatabase,
            sync: mockAppLanguagesSync
        )
        
        let storeInitialAppLanguage = StoreInitialAppLanguage(
            deviceSystemLanguage: MockDeviceSystemLanguage(deviceLocale: Locale(identifier: argument.deviceLanguage.rawValue)),
            userAppLanguageRepository: UserAppLanguageRepository(cache: userAppLanguageCache),
            appLanguagesRepository: appLanguagesRepository
        )
        
        var resultRef: AppLanguageDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
                
        await confirmation(expectedCount: 1) { confirmation in
            
            storeInitialAppLanguage
                .storeInitialAppLanguagePublisher()
                .sink { (result: AppLanguageDomainModel) in
                    
                    confirmation()
                    
                    resultRef = result
                }
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
    @MainActor func appLanguageSetAndSupportedShowsMyAppLanguage(argument: TestArgument) async {
        
        let testsDiContainer = TestsDiContainer()
        
        let testsRealmDatabase: LegacyRealmDatabase = testsDiContainer.dataLayer.getSharedLegacyRealmDatabase()
        
        let appLanguages: [AppLanguageCodable] = [
            AppLanguageCodable(languageCode: "ar", languageDirection: .rightToLeft, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "en", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "es", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hans"),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hant"),
            AppLanguageCodable(languageCode: "lv", languageDirection: .leftToRight, languageScriptCode: nil)
        ]
        
        let mockAppLanguagesSync: AppLanguagesRepositorySyncInterface = MockAppLanguagesRepositorySync(
            realmDatabase: testsRealmDatabase,
            appLanguages: appLanguages
        )
        
        let userAppLanguageCache: RealmUserAppLanguageCache = RealmUserAppLanguageCache(
            realmDatabase: testsRealmDatabase
        )
        
        userAppLanguageCache.storeLanguage(appLanguageId: argument.appLanguage?.rawValue ?? "")
                        
        let appLanguagesRepository: AppLanguagesRepository = testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository(
            realmDatabase: testsRealmDatabase,
            sync: mockAppLanguagesSync
        )
        
        let storeInitialAppLanguage = StoreInitialAppLanguage(
            deviceSystemLanguage: MockDeviceSystemLanguage(deviceLocale: Locale(identifier: argument.deviceLanguage.rawValue)),
            userAppLanguageRepository: UserAppLanguageRepository(cache: userAppLanguageCache),
            appLanguagesRepository: appLanguagesRepository
        )
        
        var resultRef: AppLanguageDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
                
        await confirmation(expectedCount: 1) { confirmation in
            
            storeInitialAppLanguage
                .storeInitialAppLanguagePublisher()
                .sink { (result: AppLanguageDomainModel) in
                    
                    confirmation()
                    
                    resultRef = result
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
    @MainActor func noAppLanguageSetAndDeviceLanguageIsNotASupportedAppLanguage(argument: TestArgument) async {
        
        let testsDiContainer = TestsDiContainer()
        
        let testsRealmDatabase: LegacyRealmDatabase = testsDiContainer.dataLayer.getSharedLegacyRealmDatabase()
        
        let appLanguages: [AppLanguageCodable] = [
            AppLanguageCodable(languageCode: "ar", languageDirection: .rightToLeft, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "en", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "es", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hans"),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hant"),
            AppLanguageCodable(languageCode: "lv", languageDirection: .leftToRight, languageScriptCode: nil)
        ]
        
        let mockAppLanguagesSync: AppLanguagesRepositorySyncInterface = MockAppLanguagesRepositorySync(
            realmDatabase: testsRealmDatabase,
            appLanguages: appLanguages
        )
        
        let userAppLanguageCache: RealmUserAppLanguageCache = RealmUserAppLanguageCache(
            realmDatabase: testsRealmDatabase
        )
        
        _ = userAppLanguageCache.deleteLanguage()
                                
        let appLanguagesRepository: AppLanguagesRepository = testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository(
            realmDatabase: testsRealmDatabase,
            sync: mockAppLanguagesSync
        )
        
        let storeInitialAppLanguage = StoreInitialAppLanguage(
            deviceSystemLanguage: MockDeviceSystemLanguage(deviceLocale: Locale(identifier: argument.deviceLanguage.rawValue)),
            userAppLanguageRepository: UserAppLanguageRepository(cache: userAppLanguageCache),
            appLanguagesRepository: appLanguagesRepository
        )
        
        var resultRef: AppLanguageDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
                
        await confirmation(expectedCount: 1) { confirmation in
            
            storeInitialAppLanguage
                .storeInitialAppLanguagePublisher()
                .sink { (result: AppLanguageDomainModel) in
                    
                    confirmation()
                    
                    resultRef = result
                }
                .store(in: &cancellables)
        }
        
        #expect(resultRef == argument.expectedValue)
    }
}
