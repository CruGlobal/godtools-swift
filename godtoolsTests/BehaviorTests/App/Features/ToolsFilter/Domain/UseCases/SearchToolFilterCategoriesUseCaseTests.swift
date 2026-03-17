//
//  SearchToolFilterCategoriesRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/4/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct SearchToolFilterCategoriesRepositoryTests {
    
    struct TestArgument {
        let searchString: String
        let expectedCategories: [String]
    }
    
    @Test(
        """
        Given: User is searching a category in the tools filter categories list.
        When: User inputs a search string."
        Then: I expect to see all categories that contain the search string ignoring case.
        """,
        arguments: [
            TestArgument(
                searchString: "c",
                expectedCategories: ["Canned", "Church", "church", "soccer", "soCCer"]
            ),
            TestArgument(
                searchString: "Y",
                expectedCategories: ["foody", "may", "Yellow"]
            ),
            TestArgument(
                searchString: "anD",
                expectedCategories: ["blAnd", "land", "pAnda", "sanded", "WAND", "wander"]
            )
        ]
    )
    func showsCategoriesContainingSearchString(argument: TestArgument) async {
        
        let searchCategoriesRepository = SearchToolFilterCategoriesRepository(
            stringSearcher: StringSearcher()
        )
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var searchedCategories: [String] = Array()
                
        await confirmation(expectedCount: 1) { confirmation in
            
            searchCategoriesRepository
                .getSearchResultsPublisher(for: argument.searchString, in: allCategories)
                .sink { (categories: [ToolFilterCategoryDomainModel]) in
                    
                    confirmation()
                    
                    searchedCategories = categories.map({$0.primaryText})
                }
                .store(in: &cancellables)
        }
        
        #expect(argument.expectedCategories.elementsEqual(searchedCategories))
    }
}

extension SearchToolFilterCategoriesRepositoryTests {
    
    private var allCategories: [ToolFilterCategoryDomainModel] {
        return [
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "blAnd", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "bran", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "Canned", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "Church", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "church", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "food", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "Food", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "foody", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "land", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "may", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "pAnda", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "sanded", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "soccer", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "soCCer", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "Tan", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "Tanned", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "WAND", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "wander", toolsAvailableText: ""),
            ToolFilterCategoryDomainModel(categoryId: "", translatedName: "Yellow", toolsAvailableText: "")
        ]
    }
}
