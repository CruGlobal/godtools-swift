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
import SwiftData
import RepositorySync

struct GetAllToolsUseCaseTests {

    struct ToolFixture {
        let id: String
        let category: String
        let languageCodes: [LanguageCodeDomainModel]
    }

    private let categoryConversationStarter: String = "conversation_starter"
    private let categoryGospel: String = "gospel"
    private let categoryArticles: String = "articles"
    private let categoryGrowth: String = "growth"
    private let englishLanguageId: String = "0"
    private let frenchLanguageId: String = "1"
    private let russianLanguageId: String = "2"
    private let spanishLanguageId: String = "3"
    private let conversationStarterTools: [ToolFixture]
    private let gospelTools: [ToolFixture]
    private let growthTools: [ToolFixture]
    private let articleTools: [ToolFixture]
    private let allTools: [ToolFixture]
    
    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tools list.
        When: The category filter is any and language filter is any.
        Then: I expect to see all tools.
        """
    )
    @MainActor func anyCategoryAndAnyLanguageShouldShowAllTools() async throws {
        
        let useCase = try getUseCase()
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var toolsListRef: [ToolListItemDomainModel] = Array()
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            useCase
                .execute(
                    appLanguage: "",
                    languageIdForAvailabilityText: nil,
                    filterToolsByCategory: ToolFilterCategoryDomainModel.emptyValue,
                    filterByLanguageId: nil
                )
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (tools: [ToolListItemDomainModel]) in
                    
                    guard toolsListRef.isEmpty && tools.count > 0 else {
                        return
                    }
                    
                    toolsListRef = tools
                                        
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }
        
        let toolsList: [String] = toolsListRef.map({$0.id}).sorted()
        let allTools: [String] = allTools.map({$0.id}).sorted()
        
        #expect(toolsList.count > 0)
        #expect(toolsList == allTools)
    }
    
    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tools list.
        When: The category filter is category growth and language filter is any.
        Then: I expect to see all growth tools.
        """
    )
    @MainActor func categoryGrowthCategoryAndAnyLanguageShouldShowCategoryGrowthTools() async throws {
        
        let useCase = try getUseCase()
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var toolsListRef: [ToolListItemDomainModel] = Array()
        
        let growthCategoryFilter = ToolFilterCategoryDomainModel.createCategory(id: categoryGrowth, title: "", toolsAvailable: "")
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            useCase
                .execute(
                    appLanguage: "",
                    languageIdForAvailabilityText: nil,
                    filterToolsByCategory: growthCategoryFilter,
                    filterByLanguageId: nil
                )
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (tools: [ToolListItemDomainModel]) in
                    
                    guard toolsListRef.isEmpty && tools.count > 0 else {
                        return
                    }
                    
                    toolsListRef = tools
                    
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }
        
        let toolsList: [String] = toolsListRef.map({$0.id}).sorted()
        let growthTools: [String] = growthTools.map({$0.id}).sorted()
        
        #expect(toolsList.count > 0)
        #expect(toolsList == growthTools)
    }
    
    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tools list.
        When: The category filter is any and language filter is russian.
        Then: I expect to see all tools that support the russian language.
        """
    )
    @MainActor func categoryIsAnyAndLanguageIsRussianShouldShowToolsThatSupportRussian() async throws {
        
        let useCase = try getUseCase()
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var toolsListRef: [ToolListItemDomainModel] = Array()
        
        let anyCategoryFilter = ToolFilterCategoryDomainModel.createAnyCategory(title: "", toolsAvailable: "")
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            useCase
                .execute(
                    appLanguage: "",
                    languageIdForAvailabilityText: nil,
                    filterToolsByCategory: anyCategoryFilter,
                    filterByLanguageId: russianLanguageId
                )
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (tools: [ToolListItemDomainModel]) in
                    
                    guard toolsListRef.isEmpty && tools.count > 0 else {
                        return
                    }
                    
                    toolsListRef = tools
                     
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }
        
        let toolsList: [String] = toolsListRef.map({$0.id}).sorted()
        let russianTools: [String] = getRussianTools().map({$0.id}).sorted()
        
        #expect(toolsList.count > 0)
        #expect(toolsList == russianTools)
    }
    
    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tools list.
        When: The category filter is any and language filter is spanish.
        Then: I expect to see all tools that support the spanish language.
        """
    )
    @MainActor func categoryIsAnyAndLanguageIsSpanishShouldShowToolsThatSupportSpanish() async throws {
        
        let useCase = try getUseCase()
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var toolsListRef: [ToolListItemDomainModel] = Array()
        
        let anyCategoryFilter = ToolFilterCategoryDomainModel.createAnyCategory(title: "", toolsAvailable: "")
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            useCase
                .execute(
                    appLanguage: "",
                    languageIdForAvailabilityText: nil,
                    filterToolsByCategory: anyCategoryFilter,
                    filterByLanguageId: spanishLanguageId
                )
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { (tools: [ToolListItemDomainModel]) in
                    
                    guard toolsListRef.isEmpty && tools.count > 0 else {
                        return
                    }
                    
                    toolsListRef = tools
                      
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }
        
        let toolsList: [String] = toolsListRef.map({$0.id}).sorted()
        let spanishTools: [String] = getSpanishTools().map({$0.id}).sorted()
        
        #expect(toolsList.count > 0)
        #expect(toolsList == spanishTools)
    }
    
    init() {

        let conversationStarterTools: [ToolFixture] = [
            Self.createTool(
                category: categoryConversationStarter,
                languageCodes: [.english, .french, .russian, .spanish]
            ),
            Self.createTool(
                category: categoryConversationStarter,
                languageCodes: [.english, .french]
            ),
            Self.createTool(
                category: categoryConversationStarter,
                languageCodes: [.russian, .spanish]
            ),
            Self.createTool(
                category: categoryConversationStarter,
                languageCodes: [.french, .spanish]
            )
        ]

        let gospelTools: [ToolFixture] = [
            Self.createTool(
                category: categoryGospel,
                languageCodes: [.english, .russian, .spanish]
            ),
            Self.createTool(
                category: categoryGospel,
                languageCodes: [.spanish]
            ),
            Self.createTool(
                category: categoryGospel,
                languageCodes: [.english, .french, .spanish]
            ),
            Self.createTool(
                category: categoryGospel,
                languageCodes: [.russian, .spanish]
            ),
            Self.createTool(
                category: categoryGospel,
                languageCodes: [.english]
            ),
            Self.createTool(
                category: categoryGospel,
                languageCodes: [.english, .russian]
            ),
            Self.createTool(
                category: categoryGospel,
                languageCodes: [.english, .french, .russian, .spanish]
            ),
            Self.createTool(
                category: categoryGospel,
                languageCodes: [.english, .french, .russian, .spanish]
            ),
            Self.createTool(
                category: categoryGospel,
                languageCodes: [.english, .french, .russian, .spanish]
            )
        ]

        let growthTools: [ToolFixture] = [
            Self.createTool(
                category: categoryGrowth,
                languageCodes: [.english, .russian, .spanish]
            ),
            Self.createTool(
                category: categoryGrowth,
                languageCodes: [.spanish]
            ),
            Self.createTool(
                category: categoryGrowth,
                languageCodes: [.english, .french, .spanish]
            ),
            Self.createTool(
                category: categoryGrowth,
                languageCodes: [.russian, .spanish]
            ),
            Self.createTool(
                category: categoryGrowth,
                languageCodes: [.english]
            ),
            Self.createTool(
                category: categoryGrowth,
                languageCodes: [.english, .russian]
            ),
            Self.createTool(
                category: categoryGrowth,
                languageCodes: [.english, .french, .russian, .spanish]
            ),
            Self.createTool(
                category: categoryGrowth,
                languageCodes: [.english, .french, .russian, .spanish]
            ),
            Self.createTool(
                category: categoryGrowth,
                languageCodes: [.english, .french, .russian, .spanish]
            )
        ]

        let articleTools: [ToolFixture] = [
            Self.createTool(
                category: categoryArticles,
                languageCodes: [.english, .spanish]
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

    @available(iOS 17.4, *)
    private func getUseCase() throws -> GetAllToolsUseCase {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let context: ModelContext = swiftDatabase.openContext()

        context.insertObjects(objects: getSwiftDatabaseObjects())

        try context.saveIfHasChanges()
        
        let testsDiContainer: TestsDiContainer = TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: swiftDatabase
            )
        )

        return GetAllToolsUseCase(
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            getToolsListItems: testsDiContainer.core.domainLayer.supporting.getToolsListItems()
        )
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any PersistentModel] {

        let languagesByCode: [LanguageCodeDomainModel: SwiftLanguage] = [
            .english: Self.createLanguage(id: englishLanguageId, code: .english),
            .french: Self.createLanguage(id: frenchLanguageId, code: .french),
            .russian: Self.createLanguage(id: russianLanguageId, code: .russian),
            .spanish: Self.createLanguage(id: spanishLanguageId, code: .spanish)
        ]

        let tools: [SwiftResource] = allTools.map { fixture in

            let resource = SwiftResource()
            resource.attrCategory = fixture.category
            resource.id = fixture.id
            resource.resourceType = ResourceType.tract.rawValue

            for languageCode in fixture.languageCodes {

                guard let language = languagesByCode[languageCode] else {
                    continue
                }

                resource.addLanguage(language: language)
            }

            return resource
        }

        return Array(languagesByCode.values) + tools
    }

    @available(iOS 17.4, *)
    private static func createLanguage(id: String, code: LanguageCodeDomainModel) -> SwiftLanguage {

        let language = SwiftLanguage()
        language.id = id
        language.code = code.rawValue

        return language
    }

    private static func createTool(category: String, languageCodes: [LanguageCodeDomainModel]) -> ToolFixture {

        return ToolFixture(
            id: UUID().uuidString,
            category: category,
            languageCodes: languageCodes
        )
    }

    private func getRussianGrowthTools() -> [ToolFixture] {
        return allTools.filter { (tool: ToolFixture) in
            tool.category == categoryGrowth && tool.languageCodes.contains(.russian)
        }
    }

    private func getRussianTools() -> [ToolFixture] {
        return getToolsByLanguage(language: .russian)
    }

    private func getSpanishTools() -> [ToolFixture] {
        return getToolsByLanguage(language: .spanish)
    }

    private func getToolsByLanguage(language: LanguageCodeDomainModel) -> [ToolFixture] {
        return allTools.filter { (tool: ToolFixture) in
            tool.languageCodes.contains(language)
        }
    }
}
