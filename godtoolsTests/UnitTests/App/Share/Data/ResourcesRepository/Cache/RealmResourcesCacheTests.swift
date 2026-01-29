//
//  RealmResourcesCacheTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 11/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import RepositorySync
import RealmSwift

struct RealmResourcesCacheTests {
        
    @Test()
    func filteringResourcesByCategory() async throws {
                
        let resourcesCache: ResourcesCache = try getResourcesCache()
        
        let gospelTracts: [ResourceDataModel] = resourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "gospel", resourceTypes: ResourceType.toolTypes)
        )
        
        let conversationStarters: [ResourceDataModel] = resourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "conversation_starter", resourceTypes: ResourceType.toolTypes)
        )
        
        #expect(gospelTracts.count == 6)
        #expect(conversationStarters.count == 3)
    }
    
    @Test()
    func filteringResourcesByCategoryAndLanguage() async throws {
        
        let resourcesCache: ResourcesCache = try getResourcesCache()
        
        let arabicGospelTracts = resourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "gospel", languageModelCode: "ar", resourceTypes: ResourceType.toolTypes)
        )
        
        let arabicBahrainGospelTracts = resourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "gospel", languageModelCode: "ar-BH", resourceTypes: ResourceType.toolTypes)
        )
        
        let spanishGospelTracts = resourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "gospel", languageModelCode: "es", resourceTypes: ResourceType.toolTypes)
        )
        
        let englishGospelTracts = resourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "gospel", languageModelCode: "en", resourceTypes: ResourceType.toolTypes)
        )
        
        let englishConversationStarterTools = resourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "conversation_starter", languageModelCode: "en", resourceTypes: ResourceType.toolTypes)
        )
        
        let russianConversationStarterTools = resourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "conversation_starter", languageModelCode: "ru", resourceTypes: ResourceType.toolTypes)
        )
        
        let chineseSimplifiedConversationStarterTools = resourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "conversation_starter", languageModelCode: "zh-Hans", resourceTypes: ResourceType.toolTypes)
        )
        
        let chineseTraditionalConversationStarterTools = resourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "conversation_starter", languageModelCode: "zh-Hant", resourceTypes: ResourceType.toolTypes)
        )
        
        #expect(arabicGospelTracts.count == 2)
        #expect(arabicBahrainGospelTracts.count == 1)
        #expect(spanishGospelTracts.count == 3)
        #expect(englishGospelTracts.count == 6)
        
        #expect(englishConversationStarterTools.count == 3)
        #expect(russianConversationStarterTools.count == 2)
        #expect(chineseSimplifiedConversationStarterTools.count == 1)
        #expect(chineseTraditionalConversationStarterTools.count == 2)
    }
    
    @Test()
    func filteringResourcesByHidden() async throws {
        
        let resourcesCache: ResourcesCache = try getResourcesCache()
        
        let allToolsCount: Int = try resourcesCache.persistence.getObjectCount()
        let hiddenTools = resourcesCache.getResourcesByFilter(filter: ResourcesFilter(resourceTypes: [.article, .chooseYourOwnAdventure, .lesson, .metaTool, .tract], isHidden: true))
        let visibleTools = resourcesCache.getResourcesByFilter(filter: ResourcesFilter(resourceTypes: [.article, .chooseYourOwnAdventure, .lesson, .metaTool, .tract], isHidden: false))
        let toolsIgnoringIsHidden = resourcesCache.getResourcesByFilter(filter: ResourcesFilter(resourceTypes: [.article, .chooseYourOwnAdventure, .lesson, .metaTool, .tract], isHidden: nil))
                
        #expect(hiddenTools.count == 3)
        #expect(visibleTools.count == allToolsCount - hiddenTools.count)
        #expect(allToolsCount == toolsIgnoringIsHidden.count)
    }
    
    @Test()
    func filteringResourcesByMetaTool() async throws {
        
        let resourcesCache: ResourcesCache = try getResourcesCache()
        
        let metatools = resourcesCache.getResourcesByFilter(filter: ResourcesFilter(resourceTypes: [.metaTool]))
        
        #expect(metatools.count == 3)
    }
    
    @Test()
    func filteringByVariant() async throws {
        
        let resourcesCache: ResourcesCache = try getResourcesCache()
        
        let variants = resourcesCache.getResourcesByFilter(filter: ResourcesFilter(variants: .isVariant))
        
        #expect(variants.count == 15)
    }
    
    @Test()
    func filteringByDefaultVariant() async throws {
        
        let resourcesCache: ResourcesCache = try getResourcesCache()
        
        let defaultVariants = resourcesCache.getResourcesByFilter(filter: ResourcesFilter(variants: .isDefaultVariant))
        
        #expect(defaultVariants.count == 3)
    }
    
    @Test()
    func filteringOutVariants() async throws {
        
        let resourcesCache: ResourcesCache = try getResourcesCache()
        
        let allTools = resourcesCache.getResourcesByFilter(filter: ResourcesFilter())
        let variants = resourcesCache.getResourcesByFilter(filter: ResourcesFilter(variants: .isVariant))
        let toolsExcludingVariants = resourcesCache.getResourcesByFilter(filter: ResourcesFilter(variants: .isNotVariant))
        
        #expect(toolsExcludingVariants.count == allTools.count - variants.count)
    }
}

extension RealmResourcesCacheTests {
    
    private func getResourcesCache() throws -> ResourcesCache {
        
        return ResourcesCache(
            persistence: try getRealmPersistence(),
            trackDownloadedTranslationsRepository: try getTrackDownloadedTranslationsRepository()
        )
    }
    
    private func getRealmPersistence() throws -> RealmRepositorySyncPersistence<ResourceDataModel, ResourceCodable, RealmResource> {
        
        return RealmRepositorySyncPersistence(
            database: try getRealmDatabase(),
            dataModelMapping: RealmResourceDataModelMapping()
        )
    }
    
    private func getTrackDownloadedTranslationsRepository() throws -> TrackDownloadedTranslationsRepository {
             
        return TrackDownloadedTranslationsRepository(
            cache: TrackDownloadedTranslationsCache(
                persistence: RealmRepositorySyncPersistence(
                    database: try getRealmDatabase(),
                    dataModelMapping: RealmDownloadedTranslationDataModelMapping()
                )
            )
        )
    }
    
    private func getRealmDatabase() throws -> RealmDatabase {
        
        let realmDatabase = RealmDatabase(databaseConfig: RealmDatabaseConfig.createInMemoryConfig())
                
        let realm: Realm = try realmDatabase.openRealm()
                
        let languages: [RealmLanguage] = getLanguages()
                
        let resources: [RealmResource] = getGospelTracts(languages: languages) +
        getChooseYourOwnAdventureTools(languages: languages) +
        getLessons(languages: languages) +
        getHiddenTools(languages: languages) +
        getMetatoolsAndVariants(languages: languages)
        
        // add objects to realm database
        
        let objects: [Object] = languages + resources
        
        do {
            
            try realm.write {
                realm.add(objects, update: .all)
            }
        }
        catch let error {
            
            assertionFailure(error.localizedDescription)
        }

        return realmDatabase
    }
    
    private func getNewLanguage(id: String, code: BCP47LanguageIdentifier) -> RealmLanguage {
        
        let realmLanguage = RealmLanguage()
        
        realmLanguage.code = code
        realmLanguage.id = id
                
        return realmLanguage
    }
    
    private func getNewRealmResource(id: String = UUID().uuidString, category: String?, isHidden: Bool = false, resourceType: ResourceType, metatoolId: String? = nil, defaultVariant: RealmResource? = nil, variants: [RealmResource]? = nil, languages: [RealmLanguage]) -> RealmResource {
        
        let realmResource = RealmResource()

        realmResource.attrCategory = category ?? ""
        realmResource.defaultVariantId = defaultVariant?.id
        realmResource.id = id
        realmResource.isHidden = isHidden
        realmResource.resourceType = resourceType.rawValue
        realmResource.metatoolId = metatoolId
        
        for language in languages {
            realmResource.addLanguage(language: language)
        }
        
        if let variants = variants {
            for variant in variants {
                realmResource.addVariant(variant: variant)
            }
        }
        
        realmResource.setDefaultVariant(variant: defaultVariant)
                
        return realmResource
    }
    
    private func getLanguages() -> [RealmLanguage] {
        
        return [
            getNewLanguage(id: "0", code: "ar"),
            getNewLanguage(id: "1", code: "ar-BH"),
            getNewLanguage(id: "2", code: "zh-Hans"),
            getNewLanguage(id: "3", code: "zh-Hant"),
            getNewLanguage(id: "4", code: "ru"),
            getNewLanguage(id: "5", code: "es"),
            getNewLanguage(id: "6", code: "en")
        ]
    }
    
    private func getGospelTracts(languages: [RealmLanguage]) -> [RealmResource] {
        
        let gospelCategory: String = "gospel"
        let tractResource: ResourceType = .tract
              
        let englishLanguage = languages.filter({$0.id == "6"}).first!
        let arabicLanguage = languages.filter({$0.id == "0"}).first!
        let arabicBahrainLanguage = languages.filter({$0.id == "1"}).first!
        let spanishLanguage = languages.filter({$0.id == "5"}).first!
        
        return [
            getNewRealmResource(category: gospelCategory, resourceType: tractResource, languages: [arabicLanguage, englishLanguage]),
            getNewRealmResource(category: gospelCategory, resourceType: tractResource, languages: [arabicLanguage, englishLanguage]),
            getNewRealmResource(category: gospelCategory, resourceType: tractResource, languages: [arabicBahrainLanguage, englishLanguage]),
            getNewRealmResource(category: gospelCategory, resourceType: tractResource, languages: [spanishLanguage, englishLanguage]),
            getNewRealmResource(category: gospelCategory, resourceType: tractResource, languages: [spanishLanguage, englishLanguage]),
            getNewRealmResource(category: gospelCategory, resourceType: tractResource, languages: [spanishLanguage, englishLanguage])
        ]
    }
    
    private func getChooseYourOwnAdventureTools(languages: [RealmLanguage]) -> [RealmResource] {
        
        let category: String = "conversation_starter"
        let cyoaResource: ResourceType = .chooseYourOwnAdventure
        
        let englishLanguage = languages.filter({$0.id == "6"}).first!
        let chineseSimplified = languages.filter({$0.id == "2"}).first!
        let chineseTraditional = languages.filter({$0.id == "3"}).first!
        let russianLanguage = languages.filter({$0.id == "4"}).first!
        
        return [
            getNewRealmResource(category: category, resourceType: cyoaResource, languages: [chineseSimplified, englishLanguage, russianLanguage]),
            getNewRealmResource(category: category, resourceType: cyoaResource, languages: [chineseTraditional, englishLanguage, russianLanguage]),
            getNewRealmResource(category: category, resourceType: cyoaResource, languages: [chineseTraditional, englishLanguage])
        ]
    }
    
    private func getHiddenTools(languages: [RealmLanguage]) -> [RealmResource] {
        
        let arabicLanguage = languages.filter({$0.id == "0"}).first!
        let englishLanguage = languages.filter({$0.id == "6"}).first!
        let spanishLanguage = languages.filter({$0.id == "5"}).first!
        
        return [
            getNewRealmResource(category: nil, isHidden: true, resourceType: .tract, languages: [englishLanguage, arabicLanguage]),
            getNewRealmResource(category: nil, isHidden: true, resourceType: .tract, languages: [englishLanguage, spanishLanguage]),
            getNewRealmResource(category: nil, isHidden: true, resourceType: .tract, languages: [englishLanguage, spanishLanguage])
        ]
    }
    
    private func getMetatoolsAndVariants(languages: [RealmLanguage]) -> [RealmResource] {
        
        let englishLanguage = languages.filter({$0.id == "6"}).first!
        
        // metatool A and variants
        
        let metatool_A_id: String = "metatool_A"
        
        let variantsForMetatool_A: [RealmResource] = [
            getNewRealmResource(category: nil, resourceType: .tract, metatoolId: metatool_A_id, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: .tract, metatoolId: metatool_A_id, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: .tract, metatoolId: metatool_A_id, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: .tract, metatoolId: metatool_A_id, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: .tract, metatoolId: metatool_A_id, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: .tract, metatoolId: metatool_A_id, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: .tract, metatoolId: metatool_A_id, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: .tract, metatoolId: metatool_A_id, languages: [englishLanguage])
        ]
        
        let metatool_A = getNewRealmResource(id: metatool_A_id, category: nil, resourceType: .metaTool, defaultVariant: variantsForMetatool_A[5], variants: variantsForMetatool_A, languages: [englishLanguage])
        
        // metatool B and variants
        
        let metatool_B_id: String = "metatool_B"
        
        let variantsForMetatool_B: [RealmResource] = [
            getNewRealmResource(category: nil, resourceType: .tract, metatoolId: metatool_B_id, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: .tract, metatoolId: metatool_B_id, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: .tract, metatoolId: metatool_B_id, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: .tract, metatoolId: metatool_B_id, languages: [englishLanguage])
        ]
        
        let metatool_B = getNewRealmResource(id: metatool_B_id, category: nil, resourceType: .metaTool, defaultVariant: variantsForMetatool_B[1], variants: variantsForMetatool_B, languages: [englishLanguage])
        
        // metatool C and variants
        
        let metatool_C_id: String = "metatool_C"
        
        let variantsForMetatool_C: [RealmResource] = [
            getNewRealmResource(category: nil, resourceType: .tract, metatoolId: metatool_C_id, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: .tract, metatoolId: metatool_C_id, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: .tract, metatoolId: metatool_C_id, languages: [englishLanguage])
        ]
        
        let metatool_C = getNewRealmResource(id: metatool_C_id, category: nil, resourceType: .metaTool, defaultVariant: variantsForMetatool_C[0], variants: variantsForMetatool_C, languages: [englishLanguage])
        
        return [metatool_A, metatool_B, metatool_C] + variantsForMetatool_A + variantsForMetatool_B + variantsForMetatool_C
    }
    
    private func getLessons(languages: [RealmLanguage]) -> [RealmResource] {
        
        let lessonResource: ResourceType = .lesson
        
        let englishLanguage = languages.filter({$0.id == "6"}).first!
        
        return [
            getNewRealmResource(category: nil, resourceType: lessonResource, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: lessonResource, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: lessonResource, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: lessonResource, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: lessonResource, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: lessonResource, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: lessonResource, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: lessonResource, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: lessonResource, languages: [englishLanguage]),
            getNewRealmResource(category: nil, resourceType: lessonResource, languages: [englishLanguage])
        ]
    }
}
