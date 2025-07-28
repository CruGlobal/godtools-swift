//
//  GetToolsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/11/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import Combine
import RealmSwift

struct GetToolsRepositoryTests {
    
    private static let englishLanguage: RealmLanguage = Self.getLanguage(id: "0", code: .english)
    private static let frenchLanguage: RealmLanguage = Self.getLanguage(id: "1", code: .french)
    private static let russianLanguage: RealmLanguage = Self.getLanguage(id: "2", code: .russian)
    private static let spanishLanguage: RealmLanguage = Self.getLanguage(id: "3", code: .spanish)
    private static let conversationStarterTools: [RealmResource] = Self.getConversationStarterTools()
    private static let allTools: [RealmResource] = Self.getAllTools()
    private static let toolsRepository: GetToolsRepository = getToolsRepository(allTools: allTools)
    private static let categoryConversationStarter: String = "conversation_starter"
    private static let categoryGospel: String = "gospel"
    private static let categoryArticles: String = "articles"
    private static let categoryGrowth: String = "growth"
    
    @Test(
        """
        Given: User is viewing the tools list.
        When: The category filter is any and language filter is any.
        Then: I expect to see all tools.
        """
    )
    @MainActor func anyCategoryAndAnyLanguageShouldShowAllTools() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var toolsListRef: [ToolListItemDomainModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            
            Self.toolsRepository
                .getToolsPublisher(
                    translatedInAppLanguage: "",
                    languageIdForAvailabilityText: nil,
                    filterToolsByCategory: nil,
                    filterToolsByLanguage: nil
                )
                .sink { (tools: [ToolListItemDomainModel]) in
                    
                    confirmation()
                    
                    toolsListRef = tools
                }
                .store(in: &cancellables)
        }
        
        #expect(toolsListRef.map({$0.id}).sorted() == Self.allTools.map({$0.id}).sorted())
    }
    
    @Test(
        """
        Given: User is viewing the tools list.
        When: The category filter is category growth and language filter is any.
        Then: I expect to see all growth tools.
        """
    )
    @MainActor func categoryGrowthCategoryAndAnyLanguageShouldShowCategoryGrowthTools() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var toolsListRef: [ToolListItemDomainModel] = Array()
        
        let growthCategoryFilter = ToolFilterCategoryDomainModel(categoryId: Self.categoryGrowth, translatedName: "", toolsAvailableText: "")
        let anyLanguageFilter = ToolFilterAnyLanguageDomainModel(text: "", toolsAvailableText: "")
        
        await confirmation(expectedCount: 1) { confirmation in
            
            Self.toolsRepository
                .getToolsPublisher(
                    translatedInAppLanguage: "",
                    languageIdForAvailabilityText: nil,
                    filterToolsByCategory: growthCategoryFilter,
                    filterToolsByLanguage: anyLanguageFilter
                )
                .sink { (tools: [ToolListItemDomainModel]) in
                    
                    confirmation()
                    
                    toolsListRef = tools
                }
                .store(in: &cancellables)
        }
        
        #expect(toolsListRef.map({$0.id}).sorted() == Self.allTools.map({$0.id}).sorted())
    }
    
    @Test(
        """
        Given: User is viewing the tools list.
        When: The category filter is any and language filter is russian.
        Then: I expect to see all tools that support the russian language.
        """
    )
    @MainActor func categoryIsAnyAndLanguageIsRussianShouldShowToolsThatSupportRussian() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var toolsListRef: [ToolListItemDomainModel] = Array()
        
        let anyCategoryFilter = ToolFilterAnyCategoryDomainModel(
            text: "",
            toolsAvailableText: ""
        )
        
        let russianLanguageFilter = ToolFilterLanguageDomainModel(
            languageName: "",
            translatedName: "",
            toolsAvailableText: "",
            languageId: Self.getRussianLanguage().id,
            languageLocaleId: ""
        )
        
        await confirmation(expectedCount: 1) { confirmation in
            
            Self.toolsRepository
                .getToolsPublisher(
                    translatedInAppLanguage: "",
                    languageIdForAvailabilityText: nil,
                    filterToolsByCategory: anyCategoryFilter,
                    filterToolsByLanguage: russianLanguageFilter
                )
                .sink { (tools: [ToolListItemDomainModel]) in
                    
                    confirmation()
                    
                    toolsListRef = tools
                }
                .store(in: &cancellables)
        }
        
        #expect(toolsListRef.map({$0.id}).sorted() == Self.allTools.map({$0.id}).sorted())
    }
    
    @Test(
        """
        Given: User is viewing the tools list.
        When: The category filter is any and language filter is spanish.
        Then: I expect to see all tools that support the spanish language.
        """
    )
    @MainActor func categoryIsAnyAndLanguageIsSpanishShouldShowToolsThatSupportSpanish() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var toolsListRef: [ToolListItemDomainModel] = Array()
        
        let anyCategoryFilter = ToolFilterAnyCategoryDomainModel(
            text: "",
            toolsAvailableText: ""
        )
        
        let spanishLanguageFilter = ToolFilterLanguageDomainModel(
            languageName: "",
            translatedName: "",
            toolsAvailableText: "",
            languageId: Self.getSpanishLanguage().id,
            languageLocaleId: ""
        )
        
        await confirmation(expectedCount: 1) { confirmation in
            
            Self.toolsRepository
                .getToolsPublisher(
                    translatedInAppLanguage: "",
                    languageIdForAvailabilityText: nil,
                    filterToolsByCategory: anyCategoryFilter,
                    filterToolsByLanguage: spanishLanguageFilter
                )
                .sink { (tools: [ToolListItemDomainModel]) in
                    
                    confirmation()
                    
                    toolsListRef = tools
                }
                .store(in: &cancellables)
        }
        
        #expect(toolsListRef.map({$0.id}).sorted() == Self.allTools.map({$0.id}).sorted())
    }
}

extension GetToolsRepositoryTests {
    
    private static func getLanguage(id: String, code: LanguageCodeDomainModel) -> RealmLanguage {
        
        let language = RealmLanguage()
        language.id = id
        language.code = code.rawValue
        
        return language
    }
    
    private static func getTool(category: String, addLanguages: [RealmLanguage]) -> RealmResource {
        
        let resource = RealmResource()
        resource.id = UUID().uuidString
        resource.resourceType = ResourceType.tract.rawValue
        
        for language in addLanguages {
            resource.addLanguage(language: language)
        }
        
        return resource
    }
    
    private static func getConversationStarterTools() -> [RealmResource] {
        
        let category: String = Self.categoryConversationStarter
        
        return [
            getTool(
                category: category,
                addLanguages: [Self.englishLanguage, Self.frenchLanguage, Self.russianLanguage, Self.spanishLanguage]
            ),
            getTool(
                category: category,
                addLanguages: [Self.englishLanguage, Self.frenchLanguage]
            ),
            getTool(
                category: category,
                addLanguages: [Self.russianLanguage, Self.spanishLanguage]
            ),
            getTool(
                category: category,
                addLanguages: [Self.frenchLanguage, Self.spanishLanguage]
            )
        ]
    }
    
    private static func getAllTools() -> [RealmResource] {
        
        var allTools: [RealmResource] = Array()
        
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
        
        return allTools
    }
    
    private static func getToolsRepository(allTools: [RealmResource]) -> GetToolsRepository {
        
        let realmDatabase: RealmDatabase = TestsInMemoryRealmDatabase()
        
        let testsDiContainer = TestsDiContainer(realmDatabase: realmDatabase)
                    
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
        
        return getToolsRepository
    }
}
