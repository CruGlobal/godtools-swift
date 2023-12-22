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
    
    private enum Category: String {
        case article = "article"
        case gospel = "gospel"
    }
    
    private enum LanguageCode: String {
        case arabic = "ar"
        case arabicBahrain = "ar-BH"
        case bengali = "bn"
        case english = "en"
        case spanish = "es"
    }
    
    private struct ResourceData {
        let category: Category?
        let isHidden: Bool?
        let languageCode: LanguageCode?
        let resourceType: ResourceType
    }

    private let resourcesData: [ResourceData] = [
        ResourceData(category: .article, isHidden: nil, languageCode: .arabic, resourceType: .tract),
        ResourceData(category: .article, isHidden: nil, languageCode: .arabicBahrain, resourceType: .tract),
        ResourceData(category: .article, isHidden: nil, languageCode: .arabicBahrain, resourceType: .tract),
        ResourceData(category: .article, isHidden: nil, languageCode: .english, resourceType: .tract),
        ResourceData(category: .article, isHidden: nil, languageCode: .english, resourceType: .tract),
        ResourceData(category: .article, isHidden: nil, languageCode: .english, resourceType: .tract),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabic, resourceType: .tract),
        ResourceData(category: nil, isHidden: nil, languageCode: .arabic, resourceType: .lesson),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabic, resourceType: .metaTool),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabic, resourceType: .chooseYourOwnAdventure),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabic, resourceType: .tract),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabic, resourceType: .tract),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabic, resourceType: .tract),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabicBahrain, resourceType: .article),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabicBahrain, resourceType: .article),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabicBahrain, resourceType: .tract),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabicBahrain, resourceType: .tract),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabicBahrain, resourceType: .tract),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabicBahrain, resourceType: .tract),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabicBahrain, resourceType: .chooseYourOwnAdventure),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabicBahrain, resourceType: .chooseYourOwnAdventure),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabicBahrain, resourceType: .chooseYourOwnAdventure),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabicBahrain, resourceType: .metaTool),
        ResourceData(category: .gospel, isHidden: nil, languageCode: .arabicBahrain, resourceType: .metaTool),
        ResourceData(category: .gospel, isHidden: true, languageCode: .bengali, resourceType: .tract),
        ResourceData(category: nil, isHidden: true, languageCode: .bengali, resourceType: .lesson),
        ResourceData(category: nil, isHidden: true, languageCode: .bengali, resourceType: .article)
    ]
        
    private lazy var realmResourcesCache: RealmResourcesCache = {
        
        let realmDatabase = getNewTestDatabase()
        
        let realmResourcesCacheSync = RealmResourcesCacheSync(
            realmDatabase: realmDatabase,
            trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository(
                cache: TrackDownloadedTranslationsCache(realmDatabase: realmDatabase)
            )
        )
        
        let realmResourcesCache = RealmResourcesCache(
            realmDatabase: realmDatabase,
            resourcesSync: realmResourcesCacheSync
        )
        
        return realmResourcesCache
    }()
        
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFilteringArticleResourcesByCategory() {
        
        let articles = realmResourcesCache.getResourcesByFilter(filter: ResourcesFilter(category: RealmResourcesCacheTests.Category.article.rawValue, resourceTypes: [.tract]))
        
        XCTAssertEqual(articles.count, 6)
    }
    
    func testFilteringArticleResourcesByCategoryAndLanguage() {
        
        let arabicArticles = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.article.rawValue,
                languageCode: LanguageCode.arabic.rawValue,
                resourceTypes: [.tract]
            )
        )
        
        let arabicBahrainArticles = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.article.rawValue,
                languageCode: LanguageCode.arabicBahrain.rawValue,
                resourceTypes: [.tract]
            )
        )
        
        let englishArticles = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.article.rawValue,
                languageCode: LanguageCode.english.rawValue,
                resourceTypes: [.tract]
            )
        )
        
        XCTAssertEqual(arabicArticles.count, 1)
        XCTAssertEqual(arabicBahrainArticles.count, 2)
        XCTAssertEqual(englishArticles.count, 3)
    }
    
    func testFilteringGospelResourcesByCategoryAndLanguageAndResourceType() {
        
        let gospelArabicTracts = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.gospel.rawValue,
                languageCode: LanguageCode.arabic.rawValue,
                resourceTypes: [.tract]
            )
        )
        
        let gospelArabicMetaTools = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.gospel.rawValue,
                languageCode: LanguageCode.arabic.rawValue,
                resourceTypes: [.metaTool]
            )
        )
        
        let gospelArabicCYOAs = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.gospel.rawValue,
                languageCode: LanguageCode.arabic.rawValue,
                resourceTypes: [.chooseYourOwnAdventure]
            )
        )
        
        let allGospelArabicTools = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.gospel.rawValue,
                languageCode: LanguageCode.arabic.rawValue,
                resourceTypes: [.article, .chooseYourOwnAdventure, .tract]
            )
        )
        
        let gospelArabicBahrainArticles = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.gospel.rawValue,
                languageCode: LanguageCode.arabicBahrain.rawValue,
                resourceTypes: [.article]
            )
        )
        
        let gospelArabicBahrainTracts = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.gospel.rawValue,
                languageCode: LanguageCode.arabicBahrain.rawValue,
                resourceTypes: [.tract]
            )
        )
        
        let gospelArabicBahrainCYOAs = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.gospel.rawValue,
                languageCode: LanguageCode.arabicBahrain.rawValue,
                resourceTypes: [.chooseYourOwnAdventure]
            )
        )
        
        let gospelArabicBahrainMetaTools = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.gospel.rawValue,
                languageCode: LanguageCode.arabicBahrain.rawValue,
                resourceTypes: [.metaTool]
            )
        )
        
        let allGospelArabicBahrainTools = realmResourcesCache.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.gospel.rawValue,
                languageCode: LanguageCode.arabicBahrain.rawValue,
                resourceTypes: [.article, .chooseYourOwnAdventure, .tract]
            )
        )
        
        XCTAssertEqual(gospelArabicTracts.count, 4)
        XCTAssertEqual(gospelArabicMetaTools.count, 1)
        XCTAssertEqual(gospelArabicCYOAs.count, 1)
        XCTAssertEqual(allGospelArabicTools.count, 5)
        XCTAssertEqual(gospelArabicBahrainArticles.count, 2)
        XCTAssertEqual(gospelArabicBahrainTracts.count, 4)
        XCTAssertEqual(gospelArabicBahrainCYOAs.count, 3)
        XCTAssertEqual(gospelArabicBahrainMetaTools.count, 2)
        XCTAssertEqual(allGospelArabicBahrainTools.count, 9)
    }
    
    func testFilteringResourcesByHidden() {
        
        let allTools = realmResourcesCache.getResources()
        let hiddenTools = realmResourcesCache.getResourcesByFilter(filter: ResourcesFilter(resourceTypes: [.article, .chooseYourOwnAdventure, .lesson, .metaTool, .tract], isHidden: true))
        let visibleTools = realmResourcesCache.getResourcesByFilter(filter: ResourcesFilter(resourceTypes: [.article, .chooseYourOwnAdventure, .lesson, .metaTool, .tract], isHidden: false))
        let toolsIgnoringIsHidden = realmResourcesCache.getResourcesByFilter(filter: ResourcesFilter(resourceTypes: [.article, .chooseYourOwnAdventure, .lesson, .metaTool, .tract], isHidden: nil))
                
        XCTAssertEqual(hiddenTools.count, 3)
        XCTAssertEqual(visibleTools.count, allTools.count - hiddenTools.count) // Test non hidden tools count is correct by subtracting hidden from all tools.
        XCTAssertEqual(allTools.count, toolsIgnoringIsHidden.count) // Ignoring hidden should give us all tools.
    }
        
    private func getNewTestDatabase() -> RealmDatabase {
                
        let config = RealmDatabaseConfiguration(cacheType: .inMemory(identifier: "RealmResourcesCacheTests"), schemaVersion: 1)
        
        let realmDatabase = RealmDatabase(databaseConfiguration: config)
                
        let realm = realmDatabase.openRealm()
                
        let realmResources = resourcesData.map({
            self.mapToRealmResource(resourceData: $0)
        })

        do {
            
            try realm.write {
                realm.add(realmResources, update: .all)
            }
        }
        catch let error {
            
            assertionFailure(error.localizedDescription)
        }
        
        return realmDatabase
    }
    
    private func mapToRealmResource(resourceData: ResourceData) -> RealmResource {
        
        let resource = RealmResource()
        
        resource.attrCategory = resourceData.category?.rawValue ?? ""
        resource.id = UUID().uuidString
        resource.isHidden = resourceData.isHidden ?? false
        resource.resourceType = resourceData.resourceType.rawValue
        
        let language = RealmLanguage()
        language.id = UUID().uuidString
        
        if let languageCode = resourceData.languageCode?.rawValue {
            
            language.code = languageCode
        }
        
        resource.languages.append(language)
        
        return resource
    }
}
