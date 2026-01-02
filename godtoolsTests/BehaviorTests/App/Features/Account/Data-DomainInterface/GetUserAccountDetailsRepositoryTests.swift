//
//  GetUserAccountDetailsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 8/1/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine
import Foundation

struct GetUserAccountDetailsRepositoryTests {
    
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
    @MainActor func testGetUserAccountDetailsInAppLanguage(argument: TestArgument) async {
        
        let getUserAccountDetailsRepository = getUserDetailsRepository()
        
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getUserAccountDetailsRepository.getUserAccountDetailsPublisher(appLanguage: argument.appLanguage.rawValue)
                .sink { (result: UserAccountDetailsDomainModel) in
                    
                    confirmation()
                    userAccountDetails = result
                }
                .store(in: &cancellables)
            
            let locale = Locale(identifier: argument.appLanguage.rawValue)
            let createdAtDateString = getDateFormatter(locale: locale).string(from: Self.userCreatedAt)
            let joinedOnStringExpected = "\(argument.joinedOnString) \(createdAtDateString)"
            
            #expect(userAccountDetails?.name == Self.userFullName)
            #expect(userAccountDetails?.joinedOnString == joinedOnStringExpected)
        }
    }
    
    @Test(
        """
        Given: User is logged in but user details are nil
        When: The user navigates to the Activity page
        Then: Activity page should populate with empty strings
        """
    )
    @MainActor func testGetNilUserDetails() async {
        
        let getUserAccountDetailsRepository = getUserDetailsRepository(emptyRealm: true)
        
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getUserAccountDetailsRepository.getUserAccountDetailsPublisher(appLanguage: LanguageCodeDomainModel.english.rawValue)
                .sink { (result: UserAccountDetailsDomainModel) in
                    
                    confirmation()
                    userAccountDetails = result
                }
                .store(in: &cancellables)
            
            #expect(userAccountDetails?.name == "")
            #expect(userAccountDetails?.joinedOnString == "")
        }
    }
    
    @Test(
        """
        Given: User is logged in but their full name is nil
        When: The user navigates to the Activity page
        Then: Activity page should populate the user's name using given and family names.
        """
    )
    @MainActor func testGetUserDetailsWithNilName() async {
        
        let getUserAccountDetailsRepository = getUserDetailsRepository(name: nil)
        
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getUserAccountDetailsRepository.getUserAccountDetailsPublisher(appLanguage: LanguageCodeDomainModel.english.rawValue)
                .sink { (result: UserAccountDetailsDomainModel) in
                    
                    confirmation()
                    userAccountDetails = result
                }
                .store(in: &cancellables)
            
            #expect(userAccountDetails?.name == "\(Self.userGivenName) \(Self.userFamilyName)")
        }
    }
    
    @Test(
        """
        Given: User is logged in but their family name and full name is nil
        When: The user navigates to the Activity page
        Then: Activity page should populate the user's name with the user's given name.
        """
    )
    @MainActor func testGetUserDetailsWithNilFamilyAndFullNames() async {
        
        let getUserAccountDetailsRepository = getUserDetailsRepository(familyName: nil, name: nil)
        
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getUserAccountDetailsRepository.getUserAccountDetailsPublisher(appLanguage: LanguageCodeDomainModel.english.rawValue)
                .sink { (result: UserAccountDetailsDomainModel) in
                    
                    confirmation()
                    userAccountDetails = result
                }
                .store(in: &cancellables)
            
            #expect(userAccountDetails?.name == Self.userGivenName)
        }
    }
    
    @Test(
        """
        Given: User is logged in but all names are nil
        When: The user navigates to the Activity page
        Then: Activity page should populate the user's name with an empty string
        """
    )
    @MainActor func testGetUserDetailsWithAllNilNames() async {
        
        let getUserAccountDetailsRepository = getUserDetailsRepository(familyName: nil, givenName: nil, name: nil)
        
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getUserAccountDetailsRepository.getUserAccountDetailsPublisher(appLanguage: LanguageCodeDomainModel.english.rawValue)
                .sink { (result: UserAccountDetailsDomainModel) in
                    
                    confirmation()
                    userAccountDetails = result
                }
                .store(in: &cancellables)
            
            #expect(userAccountDetails?.name == "")
        }
    }
    
    @Test(
        """
        Given: User is logged in but their createdAt date is nil
        When: The user navigates to the Activity page
        Then: Activity page should populate the "joined on" string with an empty string
        """
    )
    @MainActor func testGetUserDetailsWithNilJoinedOn() async {
        
        let getUserAccountDetailsRepository = getUserDetailsRepository(createdAt: nil)
        
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getUserAccountDetailsRepository.getUserAccountDetailsPublisher(appLanguage: LanguageCodeDomainModel.english.rawValue)
                .sink { (result: UserAccountDetailsDomainModel) in
                    
                    confirmation()
                    userAccountDetails = result
                }
                .store(in: &cancellables)
            
            #expect(userAccountDetails?.joinedOnString == "")
        }
    }
}

// MARK: - Private

extension GetUserAccountDetailsRepositoryTests {
    
    private func getConfiguredRealmDatabase(emptyRealm: Bool, familyName: String?, givenName: String?, name: String?, createdAt: Date?) -> TestsInMemoryRealmDatabase {
        
        if emptyRealm {
            return TestsInMemoryRealmDatabase()
        }
        
        let userDetails = RealmUserDetails()
        userDetails.id = Self.userId
        userDetails.familyName = familyName
        userDetails.givenName = givenName
        userDetails.name = name
        userDetails.createdAt = createdAt
        
        let realmAuthTokenData = RealmMobileContentAuthToken()
        realmAuthTokenData.userId = Self.userId
        
        let realmDatabase = TestsInMemoryRealmDatabase(
            addObjectsToDatabase: [userDetails, realmAuthTokenData]
        )
        
        return realmDatabase
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

    
    private func getUserDetailsRepository(emptyRealm: Bool = false, familyName: String? = userFamilyName, givenName: String? = userGivenName, name: String? = userFullName, createdAt: Date? = userCreatedAt) -> GetUserAccountDetailsRepository {
        
        let realmDatabase = getConfiguredRealmDatabase(emptyRealm: emptyRealm, familyName: familyName, givenName: givenName, name: name, createdAt: createdAt)
        
        let mockMobileContentAuthTokenKeychainAccessor = MockMobileContentAuthTokenKeychainAccessor()
        mockMobileContentAuthTokenKeychainAccessor.setUserId(Self.userId)
        
        let mobileContentAuthTokenCache = MobileContentAuthTokenCache(
            mobileContentAuthTokenKeychainAccessor: mockMobileContentAuthTokenKeychainAccessor,
            realmCache: RealmMobileContentAuthTokenCache(realmDatabase: realmDatabase)
        )
        let authTokenRepository = MobileContentAuthTokenRepository(
            api: MockMobileContentAuthTokenAPI(fetchedAuthToken: nil),
            cache: mobileContentAuthTokenCache
        )
        let userDetailsRepository = UserDetailsRepository(
            api: MockUserDetailsAPI(),
            cache: RealmUserDetailsCache(
                realmDatabase: realmDatabase,
                authTokenRepository: authTokenRepository
            )
        )
        
        let getUserAccountDetailsRepository = GetUserAccountDetailsRepository(
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
