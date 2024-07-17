//
//  StoreInitialAppLanguageTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class StoreInitialAppLanguageTests: QuickSpec {
    
    override class func spec() {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        describe("App is launched.") {
            
            context("When no app language is currently set and my device language is english.") {
                        
                let testsDiContainer = TestsDiContainer()
                
                let testsRealmDatabase: RealmDatabase = testsDiContainer.dataLayer.getSharedRealmDatabase()
                
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
                
                let userAppLanguageCache: RealmUserAppLanguageCache = RealmUserAppLanguageCache(realmDatabase: testsRealmDatabase)
                
                _ = userAppLanguageCache.deleteLanguage()
                                
                let appLanguagesRepository: AppLanguagesRepository = testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository(
                    realmDatabase: testsRealmDatabase,
                    sync: mockAppLanguagesSync
                )
                
                let storeInitialAppLanguage = StoreInitialAppLanguage(
                    deviceSystemLanguage: MockDeviceSystemLanguage.getMockEnglishDevice(),
                    userAppLanguageRepository: UserAppLanguageRepository(cache: userAppLanguageCache),
                    appLanguagesRepository: appLanguagesRepository
                )
                
                it("I expect my app language to be the device language english since english is a supported app language.") {
                                        
                    var resultRef: AppLanguageDomainModel?
                    
                    var sinkCompleted: Bool = false
                    
                    waitUntil(timeout: .seconds(15)) { done in
                        
                        storeInitialAppLanguage
                            .storeInitialAppLanguagePublisher()
                            .sink { (result: AppLanguageDomainModel) in
                            
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                resultRef = result
                                
                                sinkCompleted = true
                                
                                done()
                            }
                            .store(in: &cancellables)
                    }
                    
                    expect(resultRef).to(equal("en"))
                }
            }
            
            context("When no app language is currently set and my device language is arabic.") {
                        
                let testsDiContainer = TestsDiContainer()
                
                let testsRealmDatabase: RealmDatabase = testsDiContainer.dataLayer.getSharedRealmDatabase()
                
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
                
                let userAppLanguageCache: RealmUserAppLanguageCache = RealmUserAppLanguageCache(realmDatabase: testsRealmDatabase)
                    
                _ = userAppLanguageCache.deleteLanguage()
                
                let appLanguagesRepository: AppLanguagesRepository = testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository(
                    realmDatabase: testsRealmDatabase,
                    sync: mockAppLanguagesSync
                )
                
                let storeInitialAppLanguage = StoreInitialAppLanguage(
                    deviceSystemLanguage: MockDeviceSystemLanguage(deviceLocale: Locale(identifier: "ar")),
                    userAppLanguageRepository: UserAppLanguageRepository(cache: userAppLanguageCache),
                    appLanguagesRepository: appLanguagesRepository
                )
                
                it("I expect my app language to be the device language arabic since arabic is a supported app language.") {
                                        
                    var resultRef: AppLanguageDomainModel?
                    
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        storeInitialAppLanguage
                            .storeInitialAppLanguagePublisher()
                            .sink { (result: AppLanguageDomainModel) in
                            
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                resultRef = result
                                
                                sinkCompleted = true
                                
                                done()
                            }
                            .store(in: &cancellables)
                    }
                    
                    expect(resultRef).to(equal("ar"))
                }
            }
            
            context("When my app language is set to spanish and my device language is arabic.") {
                    
                let testsDiContainer = TestsDiContainer()
                
                let testsRealmDatabase: RealmDatabase = testsDiContainer.dataLayer.getSharedRealmDatabase()
                
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
                
                let userAppLanguageCache: RealmUserAppLanguageCache = RealmUserAppLanguageCache(realmDatabase: testsRealmDatabase)
                
                userAppLanguageCache.storeLanguage(languageId: "es")
                
                let appLanguagesRepository: AppLanguagesRepository = testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository(
                    realmDatabase: testsRealmDatabase,
                    sync: mockAppLanguagesSync
                )
                
                let storeInitialAppLanguage = StoreInitialAppLanguage(
                    deviceSystemLanguage: MockDeviceSystemLanguage(deviceLocale: Locale(identifier: "ar")),
                    userAppLanguageRepository: UserAppLanguageRepository(cache: userAppLanguageCache),
                    appLanguagesRepository: appLanguagesRepository
                )
                
                it("I expect my app language to stay in spanish.") {
                    
                    var resultRef: AppLanguageDomainModel?
                    
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        storeInitialAppLanguage
                            .storeInitialAppLanguagePublisher()
                            .sink { (result: AppLanguageDomainModel) in
                            
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                resultRef = result
                                
                                sinkCompleted = true
                                
                                done()
                            }
                            .store(in: &cancellables)
                    }
                    
                    expect(resultRef).to(equal("es"))
                }
            }
            
            context("When no app language is currently set and my device language is Czech.") {
                
                let testsDiContainer = TestsDiContainer()
                
                let testsRealmDatabase: RealmDatabase = testsDiContainer.dataLayer.getSharedRealmDatabase()
                
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
                
                let userAppLanguageCache: RealmUserAppLanguageCache = RealmUserAppLanguageCache(realmDatabase: testsRealmDatabase)
                
                _ = userAppLanguageCache.deleteLanguage()
                    
                let appLanguagesRepository: AppLanguagesRepository = testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository(
                    realmDatabase: testsRealmDatabase,
                    sync: mockAppLanguagesSync
                )
                
                let storeInitialAppLanguage = StoreInitialAppLanguage(
                    deviceSystemLanguage: MockDeviceSystemLanguage(deviceLocale: Locale(identifier: "cs")),
                    userAppLanguageRepository: UserAppLanguageRepository(cache: userAppLanguageCache),
                    appLanguagesRepository: appLanguagesRepository
                )
                
                it("I expect my app language to be english since Czech is not a supported app language.") {
                                        
                    var resultRef: AppLanguageDomainModel?
                    
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        storeInitialAppLanguage
                            .storeInitialAppLanguagePublisher()
                            .sink { (result: AppLanguageDomainModel) in
                            
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                resultRef = result
                                
                                sinkCompleted = true
                                
                                done()
                            }
                            .store(in: &cancellables)
                    }
                    
                    expect(resultRef).to(equal("en"))
                }
            }
        }
    }
}
