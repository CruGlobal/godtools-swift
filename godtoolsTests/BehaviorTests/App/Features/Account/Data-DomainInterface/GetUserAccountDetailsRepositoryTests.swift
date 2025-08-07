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
    
    @Test(
        """
        Given: User is logged in and viewing the Settings menu
        When: The user navigates to the Activity page
        Then: Activity page should populate with the user's name and "joined on" date.
        """
    )
    @MainActor func testGetUserAccountDetails() async {
        
        let getUserAccountDetailsRepository = Self.getUserDetailsRepository()
        
        var cancellables: Set<AnyCancellable> = Set()
        var userAccountDetails: UserAccountDetailsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getUserAccountDetailsRepository.getUserAccountDetailsPublisher(appLanguage: LanguageCodeDomainModel.english.rawValue)
                .sink { (result: UserAccountDetailsDomainModel) in
                    
                    confirmation()
                    userAccountDetails = result
                }
                .store(in: &cancellables)
            
            let createdAtDateString = DateFormatter.localizedString(from: Self.userCreatedAt, dateStyle: .medium, timeStyle: .none)

            #expect(userAccountDetails?.name == Self.userFullName)
            #expect(userAccountDetails?.joinedOnString == "Joined \(createdAtDateString)")
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
        
        let testsDiContainer = TestsDiContainer(realmDatabase: realmDatabase)

        let getUserAccountDetailsRepository = GetUserAccountDetailsRepository(
            userDetailsRepository: userDetailsRepository,
            localizationServices: testsDiContainer.dataLayer.getLocalizationServices()
        )
        
        return getUserAccountDetailsRepository
    }
}
