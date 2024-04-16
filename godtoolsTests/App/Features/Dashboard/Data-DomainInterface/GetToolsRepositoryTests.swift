//
//  GetToolsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/11/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble
import RealmSwift

class GetToolsRepositoryTests: QuickSpec {
    
    override class func spec() {
        
        describe("User is viewing the tools list.") {
         
            let realmDatabase: RealmDatabase = TestsInMemoryRealmDatabase()
            
            let testsDiContainer = TestsDiContainer(realmDatabase: realmDatabase)
                        
            let englishLanguage = RealmLanguage()
            englishLanguage.id = "0"
            englishLanguage.code = LanguageCodeDomainModel.english.rawValue
            
            let frenchLanguage = RealmLanguage()
            frenchLanguage.id = "1"
            frenchLanguage.code = LanguageCodeDomainModel.french.rawValue
            
            let russianLanguage = RealmLanguage()
            russianLanguage.id = "2"
            russianLanguage.code = LanguageCodeDomainModel.russian.rawValue
            
            let spanishLanguage = RealmLanguage()
            spanishLanguage.id = "3"
            spanishLanguage.code = LanguageCodeDomainModel.spanish.rawValue
            
            var allTools: [RealmResource] = Array()
            
            let categoryConversationStarter: String = "conversation_starter"
            let categoryGospel: String = "gospel"
            let categoryArticles: String = "articles"
            let categoryGrowth: String = "growth"
            let numberOfResources: Int = 20
            
            for index in 0 ..< numberOfResources {
                
                let resource = RealmResource()
                resource.id = "\(index)"
                resource.resourceType = ResourceType.tract.rawValue
                
                allTools.append(resource)
            }
            
            // conversation starter tools
            allTools[0].attrCategory = categoryConversationStarter
            allTools[0].addLanguage(language: englishLanguage)
            allTools[0].addLanguage(language: frenchLanguage)
            allTools[0].addLanguage(language: russianLanguage)
            allTools[0].addLanguage(language: spanishLanguage)

            allTools[1].attrCategory = categoryConversationStarter
            allTools[1].addLanguage(language: englishLanguage)
            allTools[1].addLanguage(language: frenchLanguage)
            
            allTools[2].attrCategory = categoryConversationStarter
            allTools[2].addLanguage(language: russianLanguage)
            allTools[2].addLanguage(language: spanishLanguage)
            
            allTools[3].attrCategory = categoryConversationStarter
            allTools[3].addLanguage(language: frenchLanguage)
            allTools[3].addLanguage(language: spanishLanguage)
            
            // gospel tools
            allTools[4].attrCategory = categoryGospel
            allTools[4].addLanguage(language: englishLanguage)
            allTools[4].addLanguage(language: russianLanguage)
            allTools[4].addLanguage(language: spanishLanguage)
            
            allTools[5].attrCategory = categoryGospel
            allTools[5].addLanguage(language: spanishLanguage)
            
            allTools[6].attrCategory = categoryGospel
            allTools[6].addLanguage(language: englishLanguage)
            allTools[6].addLanguage(language: frenchLanguage)
            allTools[6].addLanguage(language: spanishLanguage)
            
            allTools[7].attrCategory = categoryGospel
            allTools[7].addLanguage(language: russianLanguage)
            allTools[7].addLanguage(language: spanishLanguage)
            
            allTools[8].attrCategory = categoryGospel
            allTools[8].addLanguage(language: englishLanguage)
            
            allTools[9].attrCategory = categoryGospel
            allTools[9].addLanguage(language: englishLanguage)
            allTools[9].addLanguage(language: russianLanguage)
            
            allTools[10].attrCategory = categoryGospel
            allTools[10].addLanguage(language: englishLanguage)
            allTools[10].addLanguage(language: frenchLanguage)
            allTools[10].addLanguage(language: russianLanguage)
            allTools[10].addLanguage(language: spanishLanguage)
            
            allTools[11].attrCategory = categoryGospel
            allTools[11].addLanguage(language: englishLanguage)
            allTools[11].addLanguage(language: frenchLanguage)
            allTools[11].addLanguage(language: russianLanguage)
            allTools[11].addLanguage(language: spanishLanguage)
            
            allTools[12].attrCategory = categoryGospel
            allTools[12].addLanguage(language: englishLanguage)
            allTools[12].addLanguage(language: frenchLanguage)
            allTools[12].addLanguage(language: russianLanguage)
            allTools[12].addLanguage(language: spanishLanguage)
            
            // growth tools
            allTools[13].attrCategory = categoryGrowth
            allTools[13].addLanguage(language: englishLanguage)
            allTools[13].addLanguage(language: frenchLanguage)
            
            allTools[14].attrCategory = categoryGrowth
            allTools[14].addLanguage(language: englishLanguage)
            allTools[14].addLanguage(language: russianLanguage)
            
            allTools[15].attrCategory = categoryGrowth
            allTools[15].addLanguage(language: englishLanguage)
            allTools[15].addLanguage(language: frenchLanguage)
            allTools[15].addLanguage(language: russianLanguage)
            allTools[15].addLanguage(language: spanishLanguage)
            
            allTools[16].attrCategory = categoryGrowth
            allTools[16].addLanguage(language: englishLanguage)
            allTools[16].addLanguage(language: spanishLanguage)
            
            allTools[17].attrCategory = categoryGrowth
            allTools[17].addLanguage(language: englishLanguage)
            allTools[17].addLanguage(language: spanishLanguage)
            
            allTools[18].attrCategory = categoryGrowth
            allTools[18].addLanguage(language: englishLanguage)
            allTools[18].addLanguage(language: russianLanguage)
            allTools[18].addLanguage(language: spanishLanguage)
            
            // article tools
            allTools[19].attrCategory = categoryArticles
            allTools[19].addLanguage(language: englishLanguage)
            allTools[19].addLanguage(language: spanishLanguage)
            
            var growthTools: [RealmResource] = Array()
            var russianGrowthTools: [RealmResource] = Array()
            var russianTools: [RealmResource] = Array()
            var spanishTools: [RealmResource] = Array()
            
            for tool in allTools {
                
                if tool.attrCategory == categoryGrowth {
                    growthTools.append(tool)
                }
                
                if tool.attrCategory == categoryGrowth && tool.getLanguages().contains(where: {$0.code == LanguageCodeDomainModel.russian.rawValue}) {
                    russianGrowthTools.append(tool)
                }
                
                if tool.getLanguages().contains(where: {$0.code == LanguageCodeDomainModel.russian.rawValue}) {
                    russianTools.append(tool)
                }
                
                if tool.getLanguages().contains(where: {$0.code == LanguageCodeDomainModel.spanish.rawValue}) {
                    spanishTools.append(tool)
                }
            }
                        
            let realmObjectsToAdd: [Object] = allTools
            
            let realm: Realm = realmDatabase.openRealm()
                        
            do {
                try realm.write {
                    realm.add(realmObjectsToAdd, update: .all)
                }
            }
            catch _ {
                
            }
            
            let getToolsRepository = GetToolsRepository(
                resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository(),
                favoritedResourcesRepository: testsDiContainer.dataLayer.getFavoritedResourcesRepository(),
                languagesRepository: testsDiContainer.dataLayer.getLanguagesRepository(),
                getTranslatedToolName: testsDiContainer.dataLayer.getTranslatedToolName(),
                getTranslatedToolCategory: testsDiContainer.dataLayer.getTranslatedToolCategory(),
                getToolListItemInterfaceStringsRepository: testsDiContainer.dataLayer.getToolListItemInterfaceStringsRepository(),
                getTranslatedToolLanguageAvailability: testsDiContainer.dataLayer.getTranslatedToolLanguageAvailability()
            )
            
            context("When the category filter is any and language filter is any") {
                
                it("The user should see all tools") {
                    
                    var toolsList: [ToolListItemDomainModel] = Array()
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getToolsRepository
                            .getToolsPublisher(translatedInAppLanguage: "", languageForAvailabilityText: nil, filterToolsByCategory: nil, filterToolsByLanguage: nil)
                            .sink { (tools: [ToolListItemDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                toolsList = tools
                                
                                done()
                            }
                    }
                    
                    expect(toolsList.count).to(equal(allTools.count))
                }
            }
            
            context("When the category filter is \(categoryGrowth) and language filter is any") {
                
                it("The user should see all growth tools") {
                    
                    var toolsList: [ToolListItemDomainModel] = Array()
                    var sinkCompleted: Bool = false
                    
                    let growthCategoryFilter: CategoryFilterDomainModel = .category(categoryId: categoryGrowth, translatedName: "", toolsAvailableText: "")
                    
                    waitUntil { done in
                        
                        _ = getToolsRepository
                            .getToolsPublisher(translatedInAppLanguage: "", languageForAvailabilityText: nil, filterToolsByCategory: growthCategoryFilter, filterToolsByLanguage: nil)
                            .sink { (tools: [ToolListItemDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                toolsList = tools
                                
                                done()
                            }
                    }
                    
                    expect(toolsList.count).to(equal(growthTools.count))
                }
            }
            
            context("When the category filter is any and language filter is russian") {
                
                it("The user should see all tools that support the russian language") {
                    
                    var toolsList: [ToolListItemDomainModel] = Array()
                    var sinkCompleted: Bool = false
                    
                    let languageModel = LanguageDomainModel(analyticsContentLanguage: "", dataModelId: russianLanguage.id, direction: .leftToRight, localeIdentifier: "", translatedName: "")
                    
                    let languageFilter: LanguageFilterDomainModel = .language(languageName: "", toolsAvailableText: "", languageModel: languageModel)
                    
                    waitUntil { done in
                        
                        _ = getToolsRepository
                            .getToolsPublisher(translatedInAppLanguage: "", languageForAvailabilityText: nil, filterToolsByCategory: nil, filterToolsByLanguage: languageFilter)
                            .sink { (tools: [ToolListItemDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                toolsList = tools
                                
                                done()
                            }
                    }
                    
                    expect(toolsList.count).to(equal(russianTools.count))
                }
            }
            
            context("When the category filter is any and language filter is spanish") {
                
                it("The user should see all tools that support the spanish language") {
                    
                    var toolsList: [ToolListItemDomainModel] = Array()
                    var sinkCompleted: Bool = false
                    
                    let languageModel = LanguageDomainModel(analyticsContentLanguage: "", dataModelId: spanishLanguage.id, direction: .leftToRight, localeIdentifier: "", translatedName: "")
                    
                    let languageFilter: LanguageFilterDomainModel = .language(languageName: "", toolsAvailableText: "", languageModel: languageModel)
                    
                    waitUntil { done in
                        
                        _ = getToolsRepository
                            .getToolsPublisher(translatedInAppLanguage: "", languageForAvailabilityText: nil, filterToolsByCategory: nil, filterToolsByLanguage: languageFilter)
                            .sink { (tools: [ToolListItemDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                toolsList = tools
                                
                                done()
                            }
                    }
                    
                    expect(toolsList.count).to(equal(spanishTools.count))
                }
            }
        }
    }
}
