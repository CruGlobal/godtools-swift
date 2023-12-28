//
//  RealmResourcesCacheTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 11/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import XCTest
@testable import godtools
import RealmSwift
import Combine

class RealmResourcesCacheTests: XCTestCase {
    
    private lazy var realmResourcesCache: RealmResourcesCache = {
        
        let realmDatabase = getNewTestDatabase()
        
        return RealmResourcesCache(
            realmDatabase: realmDatabase,
            resourcesSync: RealmResourcesCacheSync(
                realmDatabase: realmDatabase,
                trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository(
                    cache: TrackDownloadedTranslationsCache(realmDatabase: realmDatabase)
                )
            )
        )
    }()
      
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFilteringResourcesByCategory() {
                
        let gospelTracts: [ResourceModel] = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "gospel", resourceTypes: ResourceType.toolTypes)
        )
        
        let conversationStarters: [ResourceModel] = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "conversation_starter", resourceTypes: ResourceType.toolTypes)
        )
                        
        XCTAssertEqual(gospelTracts.count, 6)
        XCTAssertEqual(conversationStarters.count, 3)
    }
    
    func testFilteringResourcesByCategoryAndLanguage() {
        
        let arabicGospelTracts = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "gospel", languageCode: "ar", resourceTypes: ResourceType.toolTypes)
        )
        
        let arabicBahrainGospelTracts = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "gospel", languageCode: "ar-BH", resourceTypes: ResourceType.toolTypes)
        )
        
        let spanishGospelTracts = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "gospel", languageCode: "es", resourceTypes: ResourceType.toolTypes)
        )
        
        let englishGospelTracts = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "gospel", languageCode: "en", resourceTypes: ResourceType.toolTypes)
        )
        
        let englishConversationStarterTools = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "conversation_starter", languageCode: "en", resourceTypes: ResourceType.toolTypes)
        )
        
        let russianConversationStarterTools = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "conversation_starter", languageCode: "ru", resourceTypes: ResourceType.toolTypes)
        )
        
        let chineseSimplifiedConversationStarterTools = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "conversation_starter", languageCode: "zh-Hans", resourceTypes: ResourceType.toolTypes)
        )
        
        let chineseTraditionalConversationStarterTools = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(category: "conversation_starter", languageCode: "zh-Hant", resourceTypes: ResourceType.toolTypes)
        )
        
        XCTAssertEqual(arabicGospelTracts.count, 2)
        XCTAssertEqual(arabicBahrainGospelTracts.count, 1)
        XCTAssertEqual(spanishGospelTracts.count, 3)
        XCTAssertEqual(englishGospelTracts.count, 6)
        
        XCTAssertEqual(englishConversationStarterTools.count, 3)
        XCTAssertEqual(russianConversationStarterTools.count, 2)
        XCTAssertEqual(chineseSimplifiedConversationStarterTools.count, 1)
        XCTAssertEqual(chineseTraditionalConversationStarterTools.count, 2)
    }
    
    func testFilteringResourcesByHidden() {
        
        let allTools = realmResourcesCache.getResources()
        let hiddenTools = realmResourcesCache.getResourcesByFilter(filter: ResourcesFilter(resourceTypes: [.article, .chooseYourOwnAdventure, .lesson, .metaTool, .tract], isHidden: true))
        let visibleTools = realmResourcesCache.getResourcesByFilter(filter: ResourcesFilter(resourceTypes: [.article, .chooseYourOwnAdventure, .lesson, .metaTool, .tract], isHidden: false))
        let toolsIgnoringIsHidden = realmResourcesCache.getResourcesByFilter(filter: ResourcesFilter(resourceTypes: [.article, .chooseYourOwnAdventure, .lesson, .metaTool, .tract], isHidden: nil))
                
        XCTAssertEqual(hiddenTools.count, 3)
        XCTAssertEqual(visibleTools.count, allTools.count - hiddenTools.count)
        XCTAssertEqual(allTools.count, toolsIgnoringIsHidden.count)
    }
    
    func testFilteringResourcesByMetaTool() {
        
        let metatools = realmResourcesCache.getResourcesByFilter(filter: ResourcesFilter(resourceTypes: [.metaTool]))
        
        XCTAssertEqual(metatools.count, 3)
    }
    
    func testFilteringByVariant() {
        
        let variants = realmResourcesCache.getResourcesByFilter(filter: ResourcesFilter(variants: .isVariant))
        
        XCTAssertEqual(variants.count, 15)
    }
    
    func testFilteringByDefaultVariant() {
        
        let defaultVariants = realmResourcesCache.getResourcesByFilter(filter: ResourcesFilter(variants: .isDefaultVariant))
        
        XCTAssertEqual(defaultVariants.count, 3)
    }
    
    func testFilteringOutVariants() {
        
        let allTools = realmResourcesCache.getResourcesByFilter(filter: ResourcesFilter())
        let variants = realmResourcesCache.getResourcesByFilter(filter: ResourcesFilter(variants: .isVariant))
        let toolsExcludingVariants = realmResourcesCache.getResourcesByFilter(filter: ResourcesFilter(variants: .isNotVariant))
        
        XCTAssertEqual(toolsExcludingVariants.count, allTools.count - variants.count)
    }
    
    private func getNewTestDatabase() -> RealmDatabase {
        
        let config = RealmDatabaseConfiguration(cacheType: .inMemory(identifier: UUID().uuidString), schemaVersion: 1)
        
        let realmDatabase = RealmDatabase(databaseConfiguration: config)
        
        let realm: Realm = realmDatabase.openRealm()
                
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
        
        let resourceModel = ResourceModel(
            abbreviation: "",
            attrAboutBannerAnimation: "",
            attrAboutOverviewVideoYoutube: "",
            attrBanner: "",
            attrBannerAbout: "",
            attrCategory: category ?? "",
            attrDefaultOrder: 0,
            attrSpotlight: false,
            defaultVariantId: defaultVariant?.id,
            id: UUID().uuidString,
            isHidden: isHidden,
            manifest: "",
            metatoolId: metatoolId,
            name: "",
            oneskyProjectId: 0,
            resourceDescription: "",
            resourceType: resourceType.rawValue,
            totalViews: 0,
            type: "",
            latestTranslationIds: [],
            attachmentIds: [],
            languageIds: [],
            variantIds: []
        )
        
        let realmResource = RealmResource()
        realmResource.mapFrom(model: resourceModel)
        
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
