//
//  GetDownloadToolProgressInterfaceStringsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine
import RealmSwift

struct GetDownloadToolProgressInterfaceStringsRepositoryTests {
    
    private static let favoritedToolId: String = "1"
    private static let unFavoritedToolId: String = "2"
    private static let unFavoritableToolId: String = "3"
    private static let downloadToolMessage: String = "Downloading tool."
    private static let favoriteThisToolForOfflineUseMessage: String = "Downloading tool. Favorite this tool for offline use."
    
    @Test(
        """
        Given: User tapped a tool and is viewing the tool download progress.
        When: The tapped tool is a favorited tool.
        Then: The message should be the downloading tool message.
        """
    )
    func correctMessageShowsWhenDownloadingAFavoritedTool() async {
        
        let downloadToolProgressInterfaceStringsRepository: GetDownloadToolProgressInterfaceStringsRepository = Self.getDownloadToolProgressInterfaceStringsRepository()
        
        var cancellables: Set<AnyCancellable> = Set()
                
        var interfaceStringsRef: DownloadToolProgressInterfaceStringsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            downloadToolProgressInterfaceStringsRepository
                .getStringsPublisher(toolId: Self.favoritedToolId, translateInAppLanguage: LanguageCodeDomainModel.english.value)
                .sink { (interfaceStrings: DownloadToolProgressInterfaceStringsDomainModel) in
                    
                    confirmation()
                    
                    interfaceStringsRef = interfaceStrings
                }
                .store(in: &cancellables)
        }
        
        #expect(interfaceStringsRef?.downloadMessage == Self.downloadToolMessage)
    }
    
    @Test(
        """
        Given: User tapped a tool and is viewing the tool download progress.
        When: The tapped tool is not a favorited tool.
        Then: The message should be the downloading tool message with favorite this tool for offline use messaging.
        """
    )
    func correctMessageShowsWhenDownloadingAToolThatIsNotFavoritedButCanBeFavorited() async {
        
        let downloadToolProgressInterfaceStringsRepository: GetDownloadToolProgressInterfaceStringsRepository = Self.getDownloadToolProgressInterfaceStringsRepository()
        
        var cancellables: Set<AnyCancellable> = Set()
                
        var interfaceStringsRef: DownloadToolProgressInterfaceStringsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            downloadToolProgressInterfaceStringsRepository
                .getStringsPublisher(toolId: Self.unFavoritedToolId, translateInAppLanguage: LanguageCodeDomainModel.english.value)
                .sink { (interfaceStrings: DownloadToolProgressInterfaceStringsDomainModel) in
                    
                    confirmation()
                    
                    interfaceStringsRef = interfaceStrings
                }
                .store(in: &cancellables)
        }
        
        #expect(interfaceStringsRef?.downloadMessage == Self.favoriteThisToolForOfflineUseMessage)
    }
    
    @Test(
        """
        Given: User tapped a tool and is viewing the tool download progress.
        When: The tapped tool is a tool that can't be favorited.
        Then: The message should be the downloading tool message.
        """
    )
    func correctMessageShowsWhenDownloadingAToolThatCantBeFavorited() async {
        
        let downloadToolProgressInterfaceStringsRepository: GetDownloadToolProgressInterfaceStringsRepository = Self.getDownloadToolProgressInterfaceStringsRepository()
        
        var cancellables: Set<AnyCancellable> = Set()
                
        var interfaceStringsRef: DownloadToolProgressInterfaceStringsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            downloadToolProgressInterfaceStringsRepository
                .getStringsPublisher(toolId: Self.unFavoritableToolId, translateInAppLanguage: LanguageCodeDomainModel.english.value)
                .sink { (interfaceStrings: DownloadToolProgressInterfaceStringsDomainModel) in
                    
                    confirmation()
                    
                    interfaceStringsRef = interfaceStrings
                }
                .store(in: &cancellables)
        }
        
        #expect(interfaceStringsRef?.downloadMessage == Self.downloadToolMessage)
    }
}

extension GetDownloadToolProgressInterfaceStringsRepositoryTests {
    
    private static func getDownloadToolProgressInterfaceStringsRepository() -> GetDownloadToolProgressInterfaceStringsRepository {
        
        let resource_1 = RealmResource()
        let favoritedResource_1 = RealmFavoritedResource()
        resource_1.id = Self.favoritedToolId
        resource_1.resourceType = ResourceType.tract.rawValue
        favoritedResource_1.resourceId = favoritedToolId
        
        let resource_2 = RealmResource()
        resource_2.id = Self.unFavoritedToolId
        resource_2.resourceType = ResourceType.tract.rawValue
        
        let resource_3 = RealmResource()
        resource_3.id = Self.unFavoritableToolId
        resource_3.resourceType = ResourceType.lesson.rawValue
        
        let realmObjectsToAdd: [Object] = [resource_1, favoritedResource_1, resource_2, resource_3]
        
        let realmDatabase: LegacyRealmDatabase = TestsInMemoryRealmDatabase(addObjectsToDatabase: realmObjectsToAdd)
        
        let testsDiContainer = TestsDiContainer(realmDatabase: realmDatabase)
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                "loading_favorited_tool": downloadToolMessage,
                "loading_unfavorited_tool": favoriteThisToolForOfflineUseMessage
            ]
        ]
        
        let getDownloadToolProgressInterfaceStringsRepository = GetDownloadToolProgressInterfaceStringsRepository(
            resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository(),
            localizationServices: MockLocalizationServices(localizableStrings: localizableStrings),
            favoritedResourcesRepository: testsDiContainer.dataLayer.getFavoritedResourcesRepository()
        )
        
        return getDownloadToolProgressInterfaceStringsRepository
    }
}
