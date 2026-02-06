//
//  GetAllToolsUseCaseTests.swift
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
import RepositorySync

@Suite(.serialized)
struct GetAllToolsUseCaseTests {
    
    private let categoryConversationStarter: String = "conversation_starter"
    private let categoryGospel: String = "gospel"
    private let categoryArticles: String = "articles"
    private let categoryGrowth: String = "growth"
    private let englishLanguageId: String = "0"
    private let frenchLanguageId: String = "1"
    private let russianLanguageId: String = "2"
    private let spanishLanguageId: String = "3"
    private let conversationStarterTools: [RealmResource]
    private let gospelTools: [RealmResource]
    private let growthTools: [RealmResource]
    private let articleTools: [RealmResource]
    private let allTools: [RealmResource]
    
    @Test(
        """
        Given: User is viewing the tools list.
        When: The category filter is any and language filter is any.
        Then: I expect to see all tools.
        """
    )
    @MainActor func anyCategoryAndAnyLanguageShouldShowAllTools() async throws {
        
        let getAllToolsUseCase = try getAllToolsUseCase()
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var toolsListRef: [ToolListItemDomainModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getAllToolsUseCase
                    .execute(
                        appLanguage: "",
                        languageIdForAvailabilityText: nil,
                        filterToolsByCategory: nil,
                        filterToolsByLanguage: nil
                    )
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { (tools: [ToolListItemDomainModel]) in
                        
                        toolsListRef = tools
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    })
                    .store(in: &cancellables)
            }
        }
        
        let toolsList: [String] = toolsListRef.map({$0.id}).sorted()
        let allTools: [String] = allTools.map({$0.id}).sorted()
        
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
    @MainActor func categoryGrowthCategoryAndAnyLanguageShouldShowCategoryGrowthTools() async throws {
        
        let getAllToolsUseCase = try getAllToolsUseCase()
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var toolsListRef: [ToolListItemDomainModel] = Array()
        
        let growthCategoryFilter = ToolFilterCategoryDomainModel(
            categoryId: categoryGrowth,
            translatedName: "",
            toolsAvailableText: ""
        )
        
        let anyLanguageFilter = ToolFilterAnyLanguageDomainModel(
            text: "",
            toolsAvailableText: "",
            numberOfToolsAvailable: 0
        )
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getAllToolsUseCase
                    .execute(
                        appLanguage: "",
                        languageIdForAvailabilityText: nil,
                        filterToolsByCategory: growthCategoryFilter,
                        filterToolsByLanguage: anyLanguageFilter
                    )
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { (tools: [ToolListItemDomainModel]) in
                        
                        toolsListRef = tools
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    })
                    .store(in: &cancellables)
            }
        }
        
        let toolsList: [String] = toolsListRef.map({$0.id}).sorted()
        let growthTools: [String] = growthTools.map({$0.id}).sorted()
        
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
    @MainActor func categoryIsAnyAndLanguageIsRussianShouldShowToolsThatSupportRussian() async throws {
        
        let getAllToolsUseCase = try getAllToolsUseCase()
        
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
            languageId: russianLanguageId,
            languageLocaleId: "",
            numberOfToolsAvailable: 0
        )
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getAllToolsUseCase
                    .execute(
                        appLanguage: "",
                        languageIdForAvailabilityText: nil,
                        filterToolsByCategory: anyCategoryFilter,
                        filterToolsByLanguage: russianLanguageFilter
                    )
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { (tools: [ToolListItemDomainModel]) in
                        
                        toolsListRef = tools
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    })
                    .store(in: &cancellables)
            }
        }
        
        let toolsList: [String] = toolsListRef.map({$0.id}).sorted()
        let russianTools: [String] = getRussianTools().map({$0.id}).sorted()
        
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
    @MainActor func categoryIsAnyAndLanguageIsSpanishShouldShowToolsThatSupportSpanish() async throws {
        
        let getAllToolsUseCase = try getAllToolsUseCase()
        
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
            languageId: spanishLanguageId,
            languageLocaleId: "",
            numberOfToolsAvailable: 0
        )
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getAllToolsUseCase
                    .execute(
                        appLanguage: "",
                        languageIdForAvailabilityText: nil,
                        filterToolsByCategory: anyCategoryFilter,
                        filterToolsByLanguage: spanishLanguageFilter
                    )
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { (tools: [ToolListItemDomainModel]) in
                        
                        toolsListRef = tools
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    })
                    .store(in: &cancellables)
            }
        }
        
        let toolsList: [String] = toolsListRef.map({$0.id}).sorted()
        let spanishTools: [String] = getSpanishTools().map({$0.id}).sorted()
        
        #expect(toolsList.count > 0)
        #expect(toolsList == spanishTools)
    }
    
    init() {
        
        let englishLanguage: RealmLanguage = Self.createLanguage(id: englishLanguageId, code: .english)
        let frenchLanguage: RealmLanguage = Self.createLanguage(id: frenchLanguageId, code: .french)
        let russianLanguage: RealmLanguage = Self.createLanguage(id: russianLanguageId, code: .russian)
        let spanishLanguage: RealmLanguage = Self.createLanguage(id: spanishLanguageId, code: .spanish)
        
        let conversationStarterTools: [RealmResource] = [
            Self.createTool(
                category: categoryConversationStarter,
                addLanguages: [englishLanguage, frenchLanguage, russianLanguage, spanishLanguage]
            ),
            Self.createTool(
                category: categoryConversationStarter,
                addLanguages: [englishLanguage, frenchLanguage]
            ),
            Self.createTool(
                category: categoryConversationStarter,
                addLanguages: [russianLanguage, spanishLanguage]
            ),
            Self.createTool(
                category: categoryConversationStarter,
                addLanguages: [frenchLanguage, spanishLanguage]
            )
        ]
        
        let gospelTools: [RealmResource] = [
            Self.createTool(
                category: categoryGospel,
                addLanguages: [englishLanguage, russianLanguage, spanishLanguage]
            ),
            Self.createTool(
                category: categoryGospel,
                addLanguages: [spanishLanguage]
            ),
            Self.createTool(
                category: categoryGospel,
                addLanguages: [englishLanguage, frenchLanguage, spanishLanguage]
            ),
            Self.createTool(
                category: categoryGospel,
                addLanguages: [russianLanguage, spanishLanguage]
            ),
            Self.createTool(
                category: categoryGospel,
                addLanguages: [englishLanguage]
            ),
            Self.createTool(
                category: categoryGospel,
                addLanguages: [englishLanguage, russianLanguage]
            ),
            Self.createTool(
                category: categoryGospel,
                addLanguages: [englishLanguage, frenchLanguage, russianLanguage, spanishLanguage]
            ),
            Self.createTool(
                category: categoryGospel,
                addLanguages: [englishLanguage, frenchLanguage, russianLanguage, spanishLanguage]
            ),
            Self.createTool(
                category: categoryGospel,
                addLanguages: [englishLanguage, frenchLanguage, russianLanguage, spanishLanguage]
            )
        ]
        
        let growthTools: [RealmResource] = [
            Self.createTool(
                category: categoryGrowth,
                addLanguages: [englishLanguage, russianLanguage, spanishLanguage]
            ),
            Self.createTool(
                category: categoryGrowth,
                addLanguages: [spanishLanguage]
            ),
            Self.createTool(
                category: categoryGrowth,
                addLanguages: [englishLanguage, frenchLanguage, spanishLanguage]
            ),
            Self.createTool(
                category: categoryGrowth,
                addLanguages: [russianLanguage, spanishLanguage]
            ),
            Self.createTool(
                category: categoryGrowth,
                addLanguages: [englishLanguage]
            ),
            Self.createTool(
                category: categoryGrowth,
                addLanguages: [englishLanguage, russianLanguage]
            ),
            Self.createTool(
                category: categoryGrowth,
                addLanguages: [englishLanguage, frenchLanguage, russianLanguage, spanishLanguage]
            ),
            Self.createTool(
                category: categoryGrowth,
                addLanguages: [englishLanguage, frenchLanguage, russianLanguage, spanishLanguage]
            ),
            Self.createTool(
                category: categoryGrowth,
                addLanguages: [englishLanguage, frenchLanguage, russianLanguage, spanishLanguage]
            )
        ]
        
        let articleTools: [RealmResource] = [
            Self.createTool(
                category: categoryArticles,
                addLanguages: [englishLanguage, spanishLanguage]
            )
        ]
        
        self.conversationStarterTools = conversationStarterTools
        self.gospelTools = gospelTools
        self.growthTools = growthTools
        self.articleTools = articleTools
        self.allTools = conversationStarterTools + gospelTools + growthTools + articleTools
    }
}

extension GetAllToolsUseCaseTests {
    
    private func getTestsDiContainer(addRealmObjects: [IdentifiableRealmObject] = Array()) throws -> TestsDiContainer {
                
        return try TestsDiContainer(
            realmFileName: String(describing: GetAllToolsUseCaseTests.self),
            addRealmObjects: allTools + addRealmObjects
        )
    }
    
    private static func createLanguage(id: String, code: LanguageCodeDomainModel) -> RealmLanguage {
        
        let language = RealmLanguage()
        language.id = id
        language.code = code.rawValue
        
        return language
    }
    
    private static func createTool(category: String, addLanguages: [RealmLanguage]) -> RealmResource {
        
        let resource = RealmResource()
        resource.attrCategory = category
        resource.id = UUID().uuidString
        resource.resourceType = ResourceType.tract.rawValue
        
        for language in addLanguages {
            resource.addLanguage(language: language)
        }
        
        return resource
    }
    
    private func getRussianGrowthTools() -> [RealmResource] {
        return allTools.filter { (resource: RealmResource) in
            resource.attrCategory == categoryGrowth && resource.getLanguages().contains(where: {$0.code == LanguageCodeDomainModel.russian.rawValue})
        }
    }
    
    private func getRussianTools() -> [RealmResource] {
        return getToolsByLanguage(language: .russian)
    }
    
    private func getSpanishTools() -> [RealmResource] {
        return getToolsByLanguage(language: .spanish)
    }
    
    private func getToolsByLanguage(language: LanguageCodeDomainModel) -> [RealmResource] {
        return allTools.filter { (resource: RealmResource) in
            resource.getLanguages().contains(where: {$0.code == language.rawValue})
        }
    }
    
    private func getAllToolsUseCase() throws -> GetAllToolsUseCase {
        
        let testsDiContainer: TestsDiContainer = try getTestsDiContainer()
        
        return GetAllToolsUseCase(
            resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository(),
            getToolsListItems: testsDiContainer.domainLayer.supporting.getToolsListItems()
        )
    }
}
