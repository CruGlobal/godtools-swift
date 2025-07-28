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
    private static let gospelTools: [RealmResource] = Self.getGospelTools()
    private static let growthTools: [RealmResource] = Self.getGrowthTools()
    private static let articleTools: [RealmResource] = Self.getArticleTools()
    private static let allTools: [RealmResource] = conversationStarterTools + gospelTools + growthTools + articleTools
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
        
        let toolsList: [String] = toolsListRef.map({$0.id}).sorted()
        let allTools: [String] = Self.allTools.map({$0.id}).sorted()
        
        #expect(toolsList.count > 0)
        #expect(toolsList == allTools)
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
        
        let growthCategoryFilter = ToolFilterCategoryDomainModel(
            categoryId: Self.categoryGrowth,
            translatedName: "",
            toolsAvailableText: ""
        )
        
        let anyLanguageFilter = ToolFilterAnyLanguageDomainModel(
            text: "",
            toolsAvailableText: ""
        )
        
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
        
        let toolsList: [String] = toolsListRef.map({$0.id}).sorted()
        let growthTools: [String] = Self.growthTools.map({$0.id}).sorted()
        
        #expect(toolsList.count > 0)
        #expect(toolsList == growthTools)
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
            languageId: Self.russianLanguage.id,
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
        
        let toolsList: [String] = toolsListRef.map({$0.id}).sorted()
        let russianTools: [String] = Self.getRussianTools().map({$0.id}).sorted()
        
        #expect(toolsList.count > 0)
        #expect(toolsList == russianTools)
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
            languageId: Self.spanishLanguage.id,
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
        
        let toolsList: [String] = toolsListRef.map({$0.id}).sorted()
        let spanishTools: [String] = Self.getSpanishTools().map({$0.id}).sorted()
        
        #expect(toolsList.count > 0)
        #expect(toolsList == spanishTools)
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
        resource.attrCategory = category
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
    
    private static func getGospelTools() -> [RealmResource] {
        
        let category: String = Self.categoryGospel
        
        return [
            getTool(
                category: category,
                addLanguages: [Self.englishLanguage, Self.russianLanguage, Self.spanishLanguage]
            ),
            getTool(
                category: category,
                addLanguages: [Self.spanishLanguage]
            ),
            getTool(
                category: category,
                addLanguages: [Self.englishLanguage, Self.frenchLanguage, Self.spanishLanguage]
            ),
            getTool(
                category: category,
                addLanguages: [Self.russianLanguage, Self.spanishLanguage]
            ),
            getTool(
                category: category,
                addLanguages: [Self.englishLanguage]
            ),
            getTool(
                category: category,
                addLanguages: [Self.englishLanguage, Self.russianLanguage]
            ),
            getTool(
                category: category,
                addLanguages: [Self.englishLanguage, Self.frenchLanguage, Self.russianLanguage, Self.spanishLanguage]
            ),
            getTool(
                category: category,
                addLanguages: [Self.englishLanguage, Self.frenchLanguage, Self.russianLanguage, Self.spanishLanguage]
            ),
            getTool(
                category: category,
                addLanguages: [Self.englishLanguage, Self.frenchLanguage, Self.russianLanguage, Self.spanishLanguage]
            )
        ]
    }
    
    private static func getGrowthTools() -> [RealmResource] {
        
        let category: String = Self.categoryGrowth
        
        return [
            getTool(
                category: category,
                addLanguages: [Self.englishLanguage, Self.frenchLanguage]
            ),
            getTool(
                category: category,
                addLanguages: [Self.englishLanguage, Self.russianLanguage]
            ),
            getTool(
                category: category,
                addLanguages: [Self.englishLanguage, Self.frenchLanguage, Self.russianLanguage, Self.spanishLanguage]
            ),
            getTool(
                category: category,
                addLanguages: [Self.englishLanguage, Self.spanishLanguage]
            ),
            getTool(
                category: category,
                addLanguages: [Self.englishLanguage, Self.spanishLanguage]
            ),
            getTool(
                category: category,
                addLanguages: [Self.englishLanguage, Self.russianLanguage, Self.spanishLanguage]
            )
        ]
    }
    
    private static func getArticleTools() -> [RealmResource] {
        
        let category: String = Self.categoryArticles
        
        return [
            getTool(
                category: category,
                addLanguages: [Self.englishLanguage, Self.spanishLanguage]
            )
        ]
    }
    
    private static func getRussianGrowthTools() -> [RealmResource] {
        return allTools.filter { (resource: RealmResource) in
            resource.attrCategory == categoryGrowth && resource.getLanguages().contains(where: {$0.code == LanguageCodeDomainModel.russian.rawValue})
        }
    }
    
    private static func getRussianTools() -> [RealmResource] {
        return getToolsByLanguage(language: .russian)
    }
    
    private static func getSpanishTools() -> [RealmResource] {
        return getToolsByLanguage(language: .spanish)
    }
    
    private static func getToolsByLanguage(language: LanguageCodeDomainModel) -> [RealmResource] {
        return allTools.filter { (resource: RealmResource) in
            resource.getLanguages().contains(where: {$0.code == language.rawValue})
        }
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
