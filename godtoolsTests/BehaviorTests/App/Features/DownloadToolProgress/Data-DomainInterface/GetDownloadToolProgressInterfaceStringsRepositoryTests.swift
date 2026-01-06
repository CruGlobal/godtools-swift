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
    @MainActor func correctMessageShowsWhenDownloadingAFavoritedTool() async {
        
        let downloadToolProgressInterfaceStringsRepository: GetDownloadToolProgressInterfaceStringsRepository = getDownloadToolProgressInterfaceStringsRepository()
        
        var cancellables: Set<AnyCancellable> = Set()
                
        var interfaceStringsRef: DownloadToolProgressInterfaceStringsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            downloadToolProgressInterfaceStringsRepository
                .getStringsPublisher(toolId: favoritedToolId, translateInAppLanguage: LanguageCodeDomainModel.english.value)
                .sink { (interfaceStrings: DownloadToolProgressInterfaceStringsDomainModel) in
                    
                    confirmation()
                    
                    interfaceStringsRef = interfaceStrings
                }
                .store(in: &cancellables)
        }
        
        #expect(interfaceStringsRef?.downloadMessage == downloadToolMessage)
    }
    
    @Test(
        """
        Given: User tapped a tool and is viewing the tool download progress.
        When: The tapped tool is not a favorited tool.
        Then: The message should be the downloading tool message with favorite this tool for offline use messaging.
        """
    )
    @MainActor func correctMessageShowsWhenDownloadingAToolThatIsNotFavoritedButCanBeFavorited() async {
        
        let downloadToolProgressInterfaceStringsRepository: GetDownloadToolProgressInterfaceStringsRepository = getDownloadToolProgressInterfaceStringsRepository()
        
        var cancellables: Set<AnyCancellable> = Set()
                
        var interfaceStringsRef: DownloadToolProgressInterfaceStringsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            downloadToolProgressInterfaceStringsRepository
                .getStringsPublisher(toolId: unFavoritedToolId, translateInAppLanguage: LanguageCodeDomainModel.english.value)
                .sink { (interfaceStrings: DownloadToolProgressInterfaceStringsDomainModel) in
                    
                    confirmation()
                    
                    interfaceStringsRef = interfaceStrings
                }
                .store(in: &cancellables)
        }
        
        #expect(interfaceStringsRef?.downloadMessage == favoriteThisToolForOfflineUseMessage)
    }
    
    @Test(
        """
        Given: User tapped a tool and is viewing the tool download progress.
        When: The tapped tool is a tool that can't be favorited.
        Then: The message should be the downloading tool message.
        """
    )
    @MainActor func correctMessageShowsWhenDownloadingAToolThatCantBeFavorited() async {
        
        let downloadToolProgressInterfaceStringsRepository: GetDownloadToolProgressInterfaceStringsRepository = getDownloadToolProgressInterfaceStringsRepository()
        
        var cancellables: Set<AnyCancellable> = Set()
                
        var interfaceStringsRef: DownloadToolProgressInterfaceStringsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            downloadToolProgressInterfaceStringsRepository
                .getStringsPublisher(toolId: unFavoritableToolId, translateInAppLanguage: LanguageCodeDomainModel.english.value)
                .sink { (interfaceStrings: DownloadToolProgressInterfaceStringsDomainModel) in
                    
                    confirmation()
                    
                    interfaceStringsRef = interfaceStrings
                }
                .store(in: &cancellables)
        }
        
        #expect(interfaceStringsRef?.downloadMessage == downloadToolMessage)
    }
}

extension GetDownloadToolProgressInterfaceStringsRepositoryTests {
    
    @MainActor private func getDownloadToolProgressInterfaceStringsRepository() -> GetDownloadToolProgressInterfaceStringsRepository {
        
        let resource_1 = RealmResource()
        let favoritedResource_1 = RealmFavoritedResource()
        resource_1.id = favoritedToolId
        resource_1.resourceType = ResourceType.tract.rawValue
        favoritedResource_1.resourceId = favoritedToolId
        
        let resource_2 = RealmResource()
        resource_2.id = unFavoritedToolId
        resource_2.resourceType = ResourceType.tract.rawValue
        
        let resource_3 = RealmResource()
        resource_3.id = unFavoritableToolId
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
