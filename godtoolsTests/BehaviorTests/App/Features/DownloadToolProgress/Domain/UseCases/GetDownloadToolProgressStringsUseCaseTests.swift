//
//  GetDownloadToolProgressStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine
import RealmSwift
import RepositorySync

@Suite(.serialized)
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
        
        let getDownloadToolProgressStringsUseCase: GetDownloadToolProgressStringsUseCase = try getDownloadToolProgressStringsUseCase()
        
        var cancellables: Set<AnyCancellable> = Set()
                
        var stringsRef: DownloadToolProgressStringsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getDownloadToolProgressStringsUseCase
                    .execute(
                        toolId: favoritedToolId,
                        appLanguage: LanguageCodeDomainModel.english.value
                    )
                    .sink { (strings: DownloadToolProgressStringsDomainModel) in
                                                
                        stringsRef = strings
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                    .store(in: &cancellables)
            }
        }
        
        #expect(stringsRef?.downloadMessage == downloadToolMessage)
    }
    
    @Test(
        """
        Given: User tapped a tool and is viewing the tool download progress.
        When: The tapped tool is not a favorited tool.
        Then: The message should be the downloading tool message with favorite this tool for offline use messaging.
        """
    )
    func correctMessageShowsWhenDownloadingAToolThatIsNotFavoritedButCanBeFavorited() async throws {
        
        let getDownloadToolProgressStringsUseCase: GetDownloadToolProgressStringsUseCase = try getDownloadToolProgressStringsUseCase()
        
        var cancellables: Set<AnyCancellable> = Set()
              
        var stringsRef: DownloadToolProgressStringsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getDownloadToolProgressStringsUseCase
                    .execute(
                        toolId: unFavoritedToolId,
                        appLanguage: LanguageCodeDomainModel.english.value
                    )
                    .sink { (strings: DownloadToolProgressStringsDomainModel) in
                                                
                        stringsRef = strings
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                    .store(in: &cancellables)
            }
        }
        
        #expect(stringsRef?.downloadMessage == favoriteThisToolForOfflineUseMessage)
    }
    
    @Test(
        """
        Given: User tapped a tool and is viewing the tool download progress.
        When: The tapped tool is a tool that can't be favorited.
        Then: The message should be the downloading tool message.
        """
    )
    func correctMessageShowsWhenDownloadingAToolThatCantBeFavorited() async throws {
        
        let getDownloadToolProgressStringsUseCase: GetDownloadToolProgressStringsUseCase = try getDownloadToolProgressStringsUseCase()
        
        var cancellables: Set<AnyCancellable> = Set()
                
        var stringsRef: DownloadToolProgressStringsDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getDownloadToolProgressStringsUseCase
                    .execute(
                        toolId: unFavoritableToolId,
                        appLanguage: LanguageCodeDomainModel.english.value
                    )
                    .sink { (strings: DownloadToolProgressStringsDomainModel) in
                                                
                        stringsRef = strings
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                    .store(in: &cancellables)
            }
        }
        
        #expect(stringsRef?.downloadMessage == downloadToolMessage)
    }
}

extension GetDownloadToolProgressStringsUseCaseTests {
    
    private func getTestsDiContainer(addRealmObjects: [IdentifiableRealmObject] = Array()) throws -> TestsDiContainer {
                
        return try TestsDiContainer(
            realmFileName: String(describing: GetDownloadToolProgressStringsUseCaseTests.self),
            addRealmObjects: addRealmObjects
        )
    }
    
    private func getRealmObjects() -> [IdentifiableRealmObject] {
        
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
        
        let realmObjects: [IdentifiableRealmObject] = [resource_1, favoritedResource_1, resource_2, resource_3]
        
        return realmObjects
    }
 
    private func getDownloadToolProgressStringsUseCase() throws -> GetDownloadToolProgressStringsUseCase {
        
        let testsDiContainer = try getTestsDiContainer(addRealmObjects: getRealmObjects())
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                "loading_favorited_tool": downloadToolMessage,
                "loading_unfavorited_tool": favoriteThisToolForOfflineUseMessage
            ]
        ]
        
        let getDownloadToolProgressStringsUseCase = GetDownloadToolProgressStringsUseCase(
            resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository(),
            localizationServices: MockLocalizationServices(localizableStrings: localizableStrings),
            favoritedResourcesRepository: testsDiContainer.dataLayer.getFavoritedResourcesRepository()
        )
        
        return getDownloadToolProgressStringsUseCase
    }
}
