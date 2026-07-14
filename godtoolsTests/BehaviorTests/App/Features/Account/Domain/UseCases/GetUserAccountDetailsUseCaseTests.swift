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

struct GetUserAccountDetailsUseCaseTests {
    
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
        
        let giveName: String = "GivenName"
        let familyName: String = "FamilyName"
        let name: String = "GivenName FamilyName"
        let createdAt: Date = Date()
        
        let userDetails = MobileContentApiUsersMeCodable(
            id: UUID().uuidString,
            createdAt: createdAt,
            familyName: familyName,
            givenName: giveName,
            name: name,
            ssoGuid: "ssoGuid",
            type: "type"
        )
        
        let useCase = try await getUseCase(userDetails: userDetails)
        
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            useCase
                .execute(
                    appLanguage: argument.appLanguage.rawValue
                )
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (result: UserAccountDetailsDomainModel) in
                    
                    guard userAccountDetails == nil else {
                        return
                    }
                    
                    userAccountDetails = result
                    
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }
        
        let locale = Locale(identifier: argument.appLanguage.rawValue)
        let createdAtDateString = getDateFormatter(locale: locale).string(from: createdAt)
        let joinedOnStringExpected = "\(argument.joinedOnString) \(createdAtDateString)"
        
        #expect(userAccountDetails?.name == name)
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
        
        let useCase = try await getUseCase(userDetails: nil)
                
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            useCase
                .execute(
                    appLanguage: LanguageCodeDomainModel.english.rawValue
                )
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (result: UserAccountDetailsDomainModel) in
                    
                    guard userAccountDetails == nil else {
                        return
                    }
                    
                    userAccountDetails = result
                                       
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
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
        
        let giveName: String = "GivenName"
        let familyName: String = "FamilyName"
        
        let userDetails = MobileContentApiUsersMeCodable(
            id: UUID().uuidString,
            createdAt: Date(),
            familyName: familyName,
            givenName: giveName,
            name: nil,
            ssoGuid: "ssoGuid",
            type: "type"
        )
        
        let useCase = try await getUseCase(userDetails: userDetails)
                        
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            useCase
                .execute(
                    appLanguage: LanguageCodeDomainModel.english.rawValue
                )
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (result: UserAccountDetailsDomainModel) in
                    
                    guard userAccountDetails == nil else {
                        return
                    }
                    
                    userAccountDetails = result
                                         
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }
        
        #expect(userAccountDetails?.name == "\(giveName) \(familyName)")
    }
    
    @Test(
        """
        Given: User is logged in but their family name and full name is nil
        When: The user navigates to the Activity page
        Then: Activity page should populate the user's name with the user's given name.
        """
    )
    @MainActor func testGetUserDetailsWithNilFamilyAndFullNames() async throws {
        
        let giveName: String = "User GivenName"
        
        let userDetails = MobileContentApiUsersMeCodable(
            id: UUID().uuidString,
            createdAt: Date(),
            familyName: nil,
            givenName: giveName,
            name: nil,
            ssoGuid: "ssoGuid",
            type: "type"
        )
        
        let useCase = try await getUseCase(userDetails: userDetails)
                
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            useCase
                .execute(
                    appLanguage: LanguageCodeDomainModel.english.rawValue
                )
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (result: UserAccountDetailsDomainModel) in
                    
                    guard userAccountDetails == nil else {
                        return
                    }
                    
                    userAccountDetails = result
                  
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }
        
        #expect(userAccountDetails?.name == giveName)
    }
    
    @Test(
        """
        Given: User is logged in but all names are nil.
        When: The user navigates to the Activity page
        Then: Activity page should populate the user's name with an empty string.
        """
    )
    @MainActor func testGetUserDetailsWithAllNilNames() async throws {
        
        let userDetails = MobileContentApiUsersMeCodable(
            id: UUID().uuidString,
            createdAt: Date(),
            familyName: nil,
            givenName: nil,
            name: nil,
            ssoGuid: "ssoGuid",
            type: "type"
        )
        
        let useCase = try await getUseCase(userDetails: userDetails)
                
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            useCase
                .execute(
                    appLanguage: LanguageCodeDomainModel.english.rawValue
                )
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (result: UserAccountDetailsDomainModel) in
                    
                    guard userAccountDetails == nil else {
                        return
                    }
                    
                    userAccountDetails = result
                                        
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
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
        
        let userDetails = MobileContentApiUsersMeCodable(
            id: UUID().uuidString,
            createdAt: nil,
            familyName: "familyName",
            givenName: "givenName",
            name: "name",
            ssoGuid: "ssoGuid",
            type: "type"
        )
        
        let useCase = try await getUseCase(userDetails: userDetails)
                
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            useCase
                .execute(
                    appLanguage: LanguageCodeDomainModel.english.rawValue
                )
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (result: UserAccountDetailsDomainModel) in
                    
                    guard userAccountDetails == nil else {
                        return
                    }
                    
                    userAccountDetails = result
                    
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }
        
        #expect(userAccountDetails?.joinedOnString == "")
    }
}

extension GetUserAccountDetailsUseCaseTests {
    
    private func getUseCase(userDetails: MobileContentApiUsersMeCodable?) async throws -> GetUserAccountDetailsUseCase {
        
        let testsDiContainer = try TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                realmDatabase: FakeRealmDatabase.createRealmDatabase()
            )
        )
        
        let userDetailsPersistence: any Persistence<UserDetailsDataModel, MobileContentApiUsersMeCodable> = RealmRepositorySyncPersistence(
            database: testsDiContainer.core.dataLayer.getSharedRealmDatabase(),
            mapping: RealmUserDetailsMapping()
        )
        
        if let userDetails = userDetails {
            try await userDetailsPersistence.writeObjects(externalObjects: [userDetails])
        }
                
        let userDetailsRepository = UserDetailsRepository(
            api: FakeUserDatailsApi(
                user: MobileContentApiUsersMeCodable.emptyValue
            ),
            cache: UserDetailsCache(
                persistence: userDetailsPersistence
            ),
            authTokenRepository: MobileContentAuthTokenRepository(
                api: FakeMobileContentAuthTokenApi(fetchedAuthToken: nil),
                cache: MobileContentAuthTokenCache(
                    mobileContentAuthTokenKeychainAccessor: FakeMobileContentAuthTokenKeychainAccessor(userId: userDetails?.id),
                    persistence: RealmRepositorySyncPersistence(
                        database: testsDiContainer.core.dataLayer.getSharedRealmDatabase(),
                        mapping: RealmMobileContentAuthTokenMapping()
                    )
                )
            )
        )
        
        return GetUserAccountDetailsUseCase(
            userDetailsRepository: userDetailsRepository,
            localizationServices: getLocalizationServices()
        )
    }
    
    private func getLocalizationServices() -> FakeLocalizationServices {
        
        let accountJoinedOn = "account.joinedOn"
        
        let localizableStrings: [FakeLocalizationServices.LocaleId: [FakeLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                accountJoinedOn: "Joined %@"
            ],
            LanguageCodeDomainModel.spanish.value: [
                accountJoinedOn: "Unirse %@"
            ]
        ]
        
        return FakeLocalizationServices(localizableStrings: localizableStrings)
    }
    
    private func getDateFormatter(locale: Locale) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }
}
