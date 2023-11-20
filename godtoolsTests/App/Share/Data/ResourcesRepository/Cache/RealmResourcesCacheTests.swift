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
        case english = "en"
        case spanish = "es"
    }
    
    private struct ResourceData {
        let category: Category?
        let languageCode: LanguageCode?
        let resourceType: ResourceType
    }

    private let resourcesData: [ResourceData] = [
        ResourceData(category: .article, languageCode: .arabic, resourceType: .tract),
        ResourceData(category: .article, languageCode: .arabicBahrain, resourceType: .tract),
        ResourceData(category: .article, languageCode: .arabicBahrain, resourceType: .tract),
        ResourceData(category: .article, languageCode: .english, resourceType: .tract),
        ResourceData(category: .article, languageCode: .english, resourceType: .tract),
        ResourceData(category: .article, languageCode: .english, resourceType: .tract),
        ResourceData(category: .gospel, languageCode: .arabic, resourceType: .tract),
        ResourceData(category: nil, languageCode: .arabic, resourceType: .lesson),
        ResourceData(category: .gospel, languageCode: .arabic, resourceType: .metaTool),
        ResourceData(category: .gospel, languageCode: .arabic, resourceType: .chooseYourOwnAdventure),
        ResourceData(category: .gospel, languageCode: .arabic, resourceType: .tract),
        ResourceData(category: .gospel, languageCode: .arabic, resourceType: .tract),
        ResourceData(category: .gospel, languageCode: .arabic, resourceType: .tract)
    ]
    
    private let numberOfArticleCategories: Int = 2
    private let numberOfGospelCategories: Int = 5
    
    private var realmResourcesCache: RealmResourcesCache?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        if realmResourcesCache == nil {
            
            let realmDatabase = getNewTestDatabase()
            
            let realmResourcesCacheSync = RealmResourcesCacheSync(
                realmDatabase: realmDatabase,
                trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository(
                    cache: TrackDownloadedTranslationsCache(realmDatabase: realmDatabase)
                )
            )
            
            realmResourcesCache = RealmResourcesCache(
                realmDatabase: realmDatabase,
                resourcesSync: realmResourcesCacheSync
            )
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFilteringArticleResourcesByCategory() {
        
        let articles = realmResourcesCache?.getResourcesByFilter(filter: ResourcesFilter(category: RealmResourcesCacheTests.Category.article.rawValue, resourceTypes: [.tract])) ?? Array()
        
        XCTAssertEqual(articles.count, 6)
    }
    
    func testFilteringArticleResourcesByCategoryAndLanguage() {
        
        let arabicArticles = realmResourcesCache?.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.article.rawValue,
                languageCode: LanguageCode.arabic.rawValue,
                resourceTypes: [.tract]
            )
        ) ?? Array()
        
        let arabicBahrainArticles = realmResourcesCache?.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.article.rawValue,
                languageCode: LanguageCode.arabicBahrain.rawValue,
                resourceTypes: [.tract]
            )
        ) ?? Array()
        
        let englishArticles = realmResourcesCache?.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.article.rawValue,
                languageCode: LanguageCode.english.rawValue,
                resourceTypes: [.tract]
            )
        ) ?? Array()
        
        XCTAssertEqual(arabicArticles.count, 1)
        XCTAssertEqual(arabicBahrainArticles.count, 2)
        XCTAssertEqual(englishArticles.count, 3)
    }
    
    func testFilteringGospelResourcesByCategoryAndLanguageAndResourceType() {
        
        let gospelArabicTracts = realmResourcesCache?.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.gospel.rawValue,
                languageCode: LanguageCode.arabic.rawValue,
                resourceTypes: [.tract]
            )
        ) ?? Array()
        
        let gospelArabicMetaTools = realmResourcesCache?.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.gospel.rawValue,
                languageCode: LanguageCode.arabic.rawValue,
                resourceTypes: [.metaTool]
            )
        ) ?? Array()
        
        let gospelArabicCYOAs = realmResourcesCache?.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.gospel.rawValue,
                languageCode: LanguageCode.arabic.rawValue,
                resourceTypes: [.chooseYourOwnAdventure]
            )
        ) ?? Array()
        
        let allGospelArabicTools = realmResourcesCache?.getResourcesByFilter(
            filter: ResourcesFilter(
                category: RealmResourcesCacheTests.Category.gospel.rawValue,
                languageCode: LanguageCode.arabic.rawValue,
                resourceTypes: [.article, .chooseYourOwnAdventure, .tract]
            )
        ) ?? Array()
        
        XCTAssertEqual(gospelArabicTracts.count, 4)
        XCTAssertEqual(gospelArabicMetaTools.count, 1)
        XCTAssertEqual(gospelArabicCYOAs.count, 1)
        XCTAssertEqual(allGospelArabicTools.count, 5)
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
