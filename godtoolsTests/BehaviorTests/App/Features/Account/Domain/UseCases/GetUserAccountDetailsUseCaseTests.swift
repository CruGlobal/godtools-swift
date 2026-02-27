//
//  GetUserAccountDetailsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 8/1/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine
import Foundation
import RepositorySync

@Suite(.serialized)
struct GetUserAccountDetailsUseCaseTests {
    
    private static let userId = "test-user-id"
    private static let userFamilyName = "Smith"
    private static let userGivenName = "John"
    private static let userFullName = "John Smith"
    private static let userCreatedAt = Date()
    
    struct TestArgument {
        let appLanguage: LanguageCodeDomainModel
        let joinedOnString: String
    }
    
    @Test(
        """
        Given: User is logged in and app language is set
        When: The user navigates to the Activity page
        Then: Activity page should populate with the user's name and "joined on" date translated in app language.
        """,
        arguments: [
            TestArgument(appLanguage: .english, joinedOnString: "Joined"),
            TestArgument(appLanguage: .spanish, joinedOnString: "Unirse")
        ]
    )
    @MainActor func testGetUserAccountDetailsInAppLanguage(argument: TestArgument) async throws {
        
        let getUserAccountDetailsUseCase: GetUserAccountDetailsUseCase = try getUserAccountDetailsUseCase()
        
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getUserAccountDetailsUseCase
                    .execute(
                        appLanguage: argument.appLanguage.rawValue
                    )
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { (result: UserAccountDetailsDomainModel) in
                        
                        userAccountDetails = result
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                        
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    })
                    .store(in: &cancellables)
            }
        }
        
        let locale = Locale(identifier: argument.appLanguage.rawValue)
        let createdAtDateString = getDateFormatter(locale: locale).string(from: Self.userCreatedAt)
        let joinedOnStringExpected = "\(argument.joinedOnString) \(createdAtDateString)"
        
        #expect(userAccountDetails?.name == Self.userFullName)
        #expect(userAccountDetails?.joinedOnString == joinedOnStringExpected)
    }
    
    @Test(
        """
        Given: User is logged in but user details are nil
        When: The user navigates to the Activity page
        Then: Activity page should populate with empty strings
        """
    )
    @MainActor func testGetNilUserDetails() async throws {
        
        let getUserAccountDetailsUseCase: GetUserAccountDetailsUseCase = try getUserAccountDetailsUseCase(emptyRealm: true)
                
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getUserAccountDetailsUseCase
                    .execute(
                        appLanguage: LanguageCodeDomainModel.english.rawValue
                    )
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { (result: UserAccountDetailsDomainModel) in
                        
                        userAccountDetails = result
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    })
                    .store(in: &cancellables)
            }
        }
        
        #expect(userAccountDetails?.name == "")
        #expect(userAccountDetails?.joinedOnString == "")
    }
    
    @Test(
        """
        Given: User is logged in but their full name is nil
        When: The user navigates to the Activity page
        Then: Activity page should populate the user's name using given and family names.
        """
    )
    @MainActor func testGetUserDetailsWithNilName() async throws {
        
        let getUserAccountDetailsUseCase: GetUserAccountDetailsUseCase = try getUserAccountDetailsUseCase(name: nil)
                
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getUserAccountDetailsUseCase
                    .execute(
                        appLanguage: LanguageCodeDomainModel.english.rawValue
                    )
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { (result: UserAccountDetailsDomainModel) in
                        
                        userAccountDetails = result
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    })
                    .store(in: &cancellables)
            }
        }
        
        #expect(userAccountDetails?.name == "\(Self.userGivenName) \(Self.userFamilyName)")
    }
    
    @Test(
        """
        Given: User is logged in but their family name and full name is nil
        When: The user navigates to the Activity page
        Then: Activity page should populate the user's name with the user's given name.
        """
    )
    @MainActor func testGetUserDetailsWithNilFamilyAndFullNames() async throws {
        
        let getUserAccountDetailsUseCase: GetUserAccountDetailsUseCase = try getUserAccountDetailsUseCase(familyName: nil, name: nil)
                
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getUserAccountDetailsUseCase
                    .execute(
                        appLanguage: LanguageCodeDomainModel.english.rawValue
                    )
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { (result: UserAccountDetailsDomainModel) in
                        
                        userAccountDetails = result

                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    })
                    .store(in: &cancellables)
            }
        }
        
        #expect(userAccountDetails?.name == Self.userGivenName)
    }
    
    @Test(
        """
        Given: User is logged in but all names are nil
        When: The user navigates to the Activity page
        Then: Activity page should populate the user's name with an empty string
        """
    )
    @MainActor func testGetUserDetailsWithAllNilNames() async throws {
        
        let getUserAccountDetailsUseCase: GetUserAccountDetailsUseCase = try getUserAccountDetailsUseCase(familyName: nil, givenName: nil, name: nil)
        
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getUserAccountDetailsUseCase
                    .execute(
                        appLanguage: LanguageCodeDomainModel.english.rawValue
                    )
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { (result: UserAccountDetailsDomainModel) in
                        
                        userAccountDetails = result
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    })
                    .store(in: &cancellables)
            }
        }
        
        #expect(userAccountDetails?.name == "")
    }
    
    @Test(
        """
        Given: User is logged in but their createdAt date is nil
        When: The user navigates to the Activity page
        Then: Activity page should populate the "joined on" string with an empty string
        """
    )
    @MainActor func testGetUserDetailsWithNilJoinedOn() async throws {
        
        let getUserAccountDetailsUseCase: GetUserAccountDetailsUseCase = try getUserAccountDetailsUseCase(createdAt: nil)
        
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getUserAccountDetailsUseCase
                    .execute(
                        appLanguage: LanguageCodeDomainModel.english.rawValue
                    )
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { (result: UserAccountDetailsDomainModel) in
                        
                        userAccountDetails = result
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    })
                    .store(in: &cancellables)
            }
        }
        
        #expect(userAccountDetails?.joinedOnString == "")
    }
}

extension GetUserAccountDetailsUseCaseTests {
    
    private func getTestsDiContainer(addRealmObjects: [IdentifiableRealmObject] = Array()) throws -> TestsDiContainer {
                
        return try TestsDiContainer(
            realmFileName: String(describing: GetUserAccountDetailsUseCaseTests.self),
            addRealmObjects: addRealmObjects
        )
    }
    
    private func getTestsDiContainer(emptyRealm: Bool, familyName: String?, givenName: String?, name: String?, createdAt: Date?) throws -> TestsDiContainer {
        
        let realmObjects: [IdentifiableRealmObject]
        
        if emptyRealm {
            
            realmObjects = Array()
        }
        else {
            
            let userDetails = RealmUserDetails()
            userDetails.id = Self.userId
            userDetails.familyName = familyName
            userDetails.givenName = givenName
            userDetails.name = name
            userDetails.createdAt = createdAt
            
            let realmAuthTokenData = RealmMobileContentAuthToken()
            realmAuthTokenData.userId = Self.userId
            
            realmObjects = [userDetails, realmAuthTokenData]
        }
        
        let testsDiContainer: TestsDiContainer = try getTestsDiContainer(addRealmObjects: realmObjects)
        
        return testsDiContainer
    }

    private func getLocalizationServices() -> MockLocalizationServices {
        
        let accountJoinedOn = "account.joinedOn"
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                accountJoinedOn: "Joined %@"
            ],
            LanguageCodeDomainModel.spanish.value: [
                accountJoinedOn: "Unirse %@"
            ]
        ]
        
        return MockLocalizationServices(localizableStrings: localizableStrings)
    }

    
    private func getUserAccountDetailsUseCase(emptyRealm: Bool = false, familyName: String? = userFamilyName, givenName: String? = userGivenName, name: String? = userFullName, createdAt: Date? = userCreatedAt) throws -> GetUserAccountDetailsUseCase {
        
        let testsDiContainer: TestsDiContainer = try getTestsDiContainer(
            emptyRealm: emptyRealm,
            familyName: familyName,
            givenName: givenName,
            name: name,
            createdAt: createdAt
        )
        
        let realmDatabase: RealmDatabase = testsDiContainer.dataLayer.getSharedRealmDatabase()
        
        let mockMobileContentAuthTokenKeychainAccessor = MockMobileContentAuthTokenKeychainAccessor()
        mockMobileContentAuthTokenKeychainAccessor.setUserId(Self.userId)
        
        let authTokenPersistence: any Persistence<MobileContentAuthTokenDataModel, MobileContentAuthTokenDecodable> = RealmRepositorySyncPersistence(
            database: realmDatabase,
            dataModelMapping: RealmMobileContentAuthTokenMapping()
        )
        
        let mobileContentAuthTokenCache = MobileContentAuthTokenCache(
            mobileContentAuthTokenKeychainAccessor: mockMobileContentAuthTokenKeychainAccessor,
            persistence: authTokenPersistence
        )
        
        let authTokenRepository = MobileContentAuthTokenRepository(
            api: MockMobileContentAuthTokenAPI(fetchedAuthToken: nil),
            cache: mobileContentAuthTokenCache
        )
        
        let userDetailsPersistence: any Persistence<UserDetailsDataModel, MobileContentApiUsersMeCodable> = RealmRepositorySyncPersistence(
            database: realmDatabase,
            dataModelMapping: RealmUserDetailsMapping()
        )
        
        let api = UserDetailsAPI(
            config: testsDiContainer.dataLayer.getAppConfig(),
            urlSessionPriority: testsDiContainer.dataLayer.getSharedUrlSessionPriority(),
            mobileContentApiAuthSession: testsDiContainer.dataLayer.getMobileContentApiAuthSession()
        )
        
        let userDetailsRepository = UserDetailsRepository(
            externalDataFetch: api,
            persistence: userDetailsPersistence,
            cache: UserDetailsCache(
                persistence: userDetailsPersistence,
                authTokenRepository: authTokenRepository
            )
        )
        
        let getUserAccountDetailsRepository = GetUserAccountDetailsUseCase(
            userDetailsRepository: userDetailsRepository,
            localizationServices: getLocalizationServices()
        )
        
        return getUserAccountDetailsRepository
    }
    
    private func getDateFormatter(locale: Locale) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }
}
