//
//  SearchToolFilterCategoriesUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/4/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct SearchToolFilterCategoriesUseCaseTests {
    
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
        
        let searchToolFilterCategoriesUseCase = getSearchToolFilterCategoriesUseCase()
                
        let searchedCategories: [ToolFilterCategoryDomainModel] = await searchToolFilterCategoriesUseCase
            .execute(searchText: argument.searchString, toolFilterCategories: allCategories)

        #expect(argument.expectedCategories.elementsEqual(searchedCategories.map{ $0.title }))
    }
}

extension SearchToolFilterCategoriesUseCaseTests {
    
    private func getSearchToolFilterCategoriesUseCase() -> SearchToolFilterCategoriesUseCase {
        return SearchToolFilterCategoriesUseCase(stringSearcher: StringSearcher())
    }
    
    private var allCategories: [ToolFilterCategoryDomainModel] {
        return [
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "blAnd", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "bran", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "Canned", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "Church", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "church", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "food", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "Food", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "foody", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "land", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "may", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "pAnda", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "sanded", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "soccer", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "soCCer", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "Tan", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "Tanned", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "WAND", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "wander", toolsAvailable: ""),
            ToolFilterCategoryDomainModel.createCategory(id: "", title: "Yellow", toolsAvailable: "")
        ]
    }
}
