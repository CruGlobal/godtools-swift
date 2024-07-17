//
//  GetDownloadToolProgressInterfaceStringsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble
import RealmSwift

class GetDownloadToolProgressInterfaceStringsRepositoryTests: QuickSpec {
    
    override class func spec() {
    
        describe("User tapped a tool and is viewing downloading tool progress.") {
         
            let realmDatabase: RealmDatabase = TestsInMemoryRealmDatabase()
            
            let testsDiContainer = TestsDiContainer(realmDatabase: realmDatabase)
            
            let favoritedToolId: String = "1"
            let unFavoritedToolId: String = "2"
            let unFavoritableToolId: String = "3"
            
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
            
            let realm: Realm = realmDatabase.openRealm()
                        
            do {
                try realm.write {
                    realm.add(realmObjectsToAdd, update: .all)
                }
            }
            catch _ {
                
            }
            
            let downloadToolMessage: String = "Downloading tool."
            let favoriteThisToolForOfflineUseMessage: String = "Downloading tool. Favorite this tool for offline use."
            
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
            
            context("When a tool is favorited.") {
                
                it("The message should be the downloading tool message.") {
                                        
                    var interfaceStringsRef: DownloadToolProgressInterfaceStringsDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getDownloadToolProgressInterfaceStringsRepository
                            .getStringsPublisher(toolId: favoritedToolId, translateInAppLanguage: LanguageCodeDomainModel.english.value)
                            .sink { (interfaceStrings: DownloadToolProgressInterfaceStringsDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCount += 1
                                
                                if sinkCount == 1 {
                                    
                                    interfaceStringsRef = interfaceStrings
                                    
                                    sinkCompleted = true
                                    
                                    done()
                                }
                            }
                    }

                    expect(interfaceStringsRef?.downloadMessage).to(equal(downloadToolMessage))
                }
            }
            
            context("When a tool is not favorited.") {
                
                it("The message should be the downloading tool message with favorite this tool for offline use messaging.") {
                                        
                    var interfaceStringsRef: DownloadToolProgressInterfaceStringsDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getDownloadToolProgressInterfaceStringsRepository
                            .getStringsPublisher(toolId: unFavoritedToolId, translateInAppLanguage: LanguageCodeDomainModel.english.value)
                            .sink { (interfaceStrings: DownloadToolProgressInterfaceStringsDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCount += 1
                                
                                if sinkCount == 1 {
                                    
                                    interfaceStringsRef = interfaceStrings
                                    
                                    sinkCompleted = true
                                    
                                    done()
                                }
                            }
                    }

                    expect(interfaceStringsRef?.downloadMessage).to(equal(favoriteThisToolForOfflineUseMessage))
                }
            }
            
            context("When a tool is not favoritable.") {
                
                it("The message should be the downloading tool message.") {
                                        
                    var interfaceStringsRef: DownloadToolProgressInterfaceStringsDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getDownloadToolProgressInterfaceStringsRepository
                            .getStringsPublisher(toolId: unFavoritableToolId, translateInAppLanguage: LanguageCodeDomainModel.english.value)
                            .sink { (interfaceStrings: DownloadToolProgressInterfaceStringsDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCount += 1
                                
                                if sinkCount == 1 {
                                    
                                    interfaceStringsRef = interfaceStrings
                                    
                                    sinkCompleted = true
                                    
                                    done()
                                }
                            }
                    }

                    expect(interfaceStringsRef?.downloadMessage).to(equal(downloadToolMessage))
                }
            }
        }
    }
}
