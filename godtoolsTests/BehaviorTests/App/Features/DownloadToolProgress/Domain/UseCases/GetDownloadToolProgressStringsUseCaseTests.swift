//
//  GetDownloadToolProgressStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import RepositorySync

struct GetDownloadToolProgressStringsUseCaseTests {
    
    private let favoritedToolId: String = "1"
    private let unFavoritedToolId: String = "2"
    private let unFavoritableToolId: String = "3"
    private let downloadToolMessage: String = "Downloading tool."
    private let favoriteThisToolForOfflineUseMessage: String = "Downloading tool. Favorite this tool for offline use."
    
    @Test(
        """
        Given: User tapped a tool and is viewing the tool download progress.
        When: The tapped tool is a favorited tool.
        Then: The message should be the downloading tool message.
        """
    )
    func correctMessageShowsWhenDownloadingAFavoritedTool() async throws {
        
        let useCase = try await getUseCase()
        
        let strings = useCase
            .execute(
                toolId: favoritedToolId,
                appLanguage: LanguageCodeDomainModel.english.value
            )
        
        #expect(strings.downloadMessage == downloadToolMessage)
    }
    
    @Test(
        """
        Given: User tapped a tool and is viewing the tool download progress.
        When: The tapped tool is not a favorited tool.
        Then: The message should be the downloading tool message with favorite this tool for offline use messaging.
        """
    )
    func correctMessageShowsWhenDownloadingAToolThatIsNotFavoritedButCanBeFavorited() async throws {
        
        let useCase = try await getUseCase()
        
        let strings = useCase
            .execute(
                toolId: unFavoritedToolId,
                appLanguage: LanguageCodeDomainModel.english.value
            )
        
        #expect(strings.downloadMessage == favoriteThisToolForOfflineUseMessage)
    }
    
    @Test(
        """
        Given: User tapped a tool and is viewing the tool download progress.
        When: The tapped tool is a tool that can't be favorited.
        Then: The message should be the downloading tool message.
        """
    )
    func correctMessageShowsWhenDownloadingAToolThatCantBeFavorited() async throws {
        
        let useCase = try await getUseCase()
        
        let strings = useCase
            .execute(
                toolId: unFavoritableToolId,
                appLanguage: LanguageCodeDomainModel.english.value
            )
        
        #expect(strings.downloadMessage == downloadToolMessage)
    }
}

extension GetDownloadToolProgressStringsUseCaseTests {
 
    private func getUseCase() async throws -> GetDownloadToolProgressStringsUseCase {
        
        let testsDiContainer = try TestsDiContainer()
        
        let favoritedTract = ResourceCodable(id: favoritedToolId, resourceType: ResourceType.tract.rawValue)
        let unfavoritedTract = ResourceCodable(id: unFavoritedToolId, resourceType: ResourceType.tract.rawValue)
        let unfavoritable = ResourceCodable(id: unFavoritableToolId, resourceType: ResourceType.lesson.rawValue)
        
        let favorite0 = FavoritedResourceDataModel(id: favoritedTract.id, createdAt: Date(), position: 0)
        
        try await testsDiContainer.core.dataLayer.getResourcesPersistence().writeObjects(externalObjects: [favoritedTract, unfavoritedTract, unfavoritable])
        try await testsDiContainer.core.dataLayer.getFavoritedResourcesPersistence().writeObjects(externalObjects: [favorite0])
        
        let localizableStrings: [FakeLocalizationServices.LocaleId: [FakeLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                "loading_favorited_tool": downloadToolMessage,
                "loading_unfavorited_tool": favoriteThisToolForOfflineUseMessage
            ]
        ]
        
        let getDownloadToolProgressStringsUseCase = GetDownloadToolProgressStringsUseCase(
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            localizationServices: FakeLocalizationServices(localizableStrings: localizableStrings),
            favoritedResourcesRepository: testsDiContainer.core.dataLayer.getFavoritedResourcesRepository()
        )
        
        return getDownloadToolProgressStringsUseCase
    }
}
