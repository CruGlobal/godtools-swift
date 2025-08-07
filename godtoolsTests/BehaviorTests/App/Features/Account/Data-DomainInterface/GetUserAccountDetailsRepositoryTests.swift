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
    @MainActor func testGetUserAccountDetails(argument: TestArgument) async {
        
        let getUserAccountDetailsRepository = Self.getUserDetailsRepository()
        
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
            let createdAtDateString = Self.getDateFormatter(locale: locale).string(from: Self.userCreatedAt)
            let joinedOnStringExpected = "\(argument.joinedOnString) \(createdAtDateString)"
            
            #expect(userAccountDetails?.name == Self.userFullName)
            #expect(userAccountDetails?.joinedOnString == joinedOnStringExpected)
        }
    }
}

// MARK: - Private

extension GetUserAccountDetailsRepositoryTests {
    
    private static func getConfiguredRealmDatabase() -> TestsInMemoryRealmDatabase {
        
        let userDetails = RealmUserDetails()
        userDetails.id = userId
        userDetails.familyName = userFamilyName
        userDetails.givenName = userGivenName
        userDetails.name = userFullName
        userDetails.createdAt = userCreatedAt
        
        let realmAuthTokenData = RealmMobileContentAuthToken()
        realmAuthTokenData.userId = userId
        
        let realmDatabase = TestsInMemoryRealmDatabase(
            addObjectsToDatabase: [userDetails, realmAuthTokenData]
        )
        
        return realmDatabase
    }

    private static func getLocalizationServices() -> MockLocalizationServices {
        
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

    
    private static func getUserDetailsRepository() -> GetUserAccountDetailsRepository {
        
        let realmDatabase = getConfiguredRealmDatabase()
        
        let mockMobileContentAuthTokenKeychainAccessor = MockMobileContentAuthTokenKeychainAccessor()
        mockMobileContentAuthTokenKeychainAccessor.setUserId(userId)
        
        let mobileContentAuthTokenCache = MobileContentAuthTokenCache(
            mobileContentAuthTokenKeychainAccessor: mockMobileContentAuthTokenKeychainAccessor,
            realmCache: RealmMobileContentAuthTokenCache(realmDatabase: realmDatabase)
        )
        let authTokenRepository = MobileContentAuthTokenRepository(
            api: MockMobileContentAuthTokenAPI(),
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
    
    private static func getDateFormatter(locale: Locale) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }
}
