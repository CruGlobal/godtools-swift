//
//  SearchToolFilterCategoriesRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/4/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class SearchToolFilterCategoriesRepositoryTests: QuickSpec {
    
    override class func spec() {
    
        var cancellables: Set<AnyCancellable> = Set()
        
        describe("User is searching a category in the tools filter categories list.") {
            
            let searchCategoriesRepository = SearchToolFilterCategoriesRepository(
                stringSearcher: StringSearcher()
            )
            
            let lowercasedSingleLetterSearchString: String = "c"
            
            context("When a user inputs a lowercased single letter search string \(lowercasedSingleLetterSearchString)") {
                
                let allCategories: [ToolFilterCategoryDomainModel] = [
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "Church", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "church", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "food", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "Food", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "soccer", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "soCCer", toolsAvailableText: "")
                ]
                
                it("I expect all categories that contain the lowercased single letter search string \(lowercasedSingleLetterSearchString) ignoring case.") {
                    
                    var searchedCategories: [String] = Array()
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        searchCategoriesRepository
                            .getSearchResultsPublisher(for: lowercasedSingleLetterSearchString, in: allCategories)
                            .sink { (categories: [ToolFilterCategoryDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                searchedCategories = categories.map({$0.primaryText})
                                
                                done()
                            }
                            .store(in: &cancellables)
                    }
                    
                    let expectedCategories: [String] = ["soccer", "soCCer", "Church", "church"]
                    let shouldNotContainCategories: [String] = ["food", "Food"]
                    
                    expect(searchedCategories.count).to(equal(expectedCategories.count))
                    expect(searchedCategories).to(contain(expectedCategories))
                    expect(searchedCategories).toNot(contain(shouldNotContainCategories))
                }
            }
            
            let uppercasedSingleLetterSearchString: String = "Y"
            
            context("When a user inputs an uppercased single letter search string \(uppercasedSingleLetterSearchString)") {
                
                let allCategories: [ToolFilterCategoryDomainModel] = [
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "Church", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "church", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "foody", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "Food", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "soccer", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "soCCer", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "Yellow", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "may", toolsAvailableText: "")
                ]
                
                it("I expect all categories that contain the uppercased single letter search string \(uppercasedSingleLetterSearchString) ignoring case.") {
                    
                    var searchedCategories: [String] = Array()
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        searchCategoriesRepository
                            .getSearchResultsPublisher(for: uppercasedSingleLetterSearchString, in: allCategories)
                            .sink { (categories: [ToolFilterCategoryDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                searchedCategories = categories.map({$0.primaryText})
                                
                                done()
                            }
                            .store(in: &cancellables)
                    }
                    
                    let expectedCategories: [String] = ["foody", "Yellow", "may"]
                    let shouldNotContainCategories: [String] = ["Church", "church", "Food", "soccer", "soCCer"]
                    
                    expect(searchedCategories.count).to(equal(expectedCategories.count))
                    expect(searchedCategories).to(contain(expectedCategories))
                    expect(searchedCategories).toNot(contain(shouldNotContainCategories))
                }
            }
            
            let multiTextSearchString: String = "anD"
            
            context("When a user inputs a multi-text search string \(multiTextSearchString)") {
                
                let allCategories: [ToolFilterCategoryDomainModel] = [
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "blAnd", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "land", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "Canned", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "WAND", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "wander", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "pAnda", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "bran", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "Tan", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "Tanned", toolsAvailableText: ""),
                    ToolFilterCategoryDomainModel(categoryId: "", translatedName: "sanded", toolsAvailableText: "")
                ]
                
                it("I expect all categories that contain the multi-text search string \(multiTextSearchString) ignoring case.") {
                    
                    var searchedCategories: [String] = Array()
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        searchCategoriesRepository
                            .getSearchResultsPublisher(for: multiTextSearchString, in: allCategories)
                            .sink { (categories: [ToolFilterCategoryDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                searchedCategories = categories.map({$0.primaryText})
                                
                                done()
                            }
                            .store(in: &cancellables)
                    }
                    
                    let expectedCategories: [String] = ["blAnd", "land", "WAND", "wander", "pAnda", "sanded"]
                    let shouldNotContainCategories: [String] = ["Canned", "bran", "Tan", "Tanned"]
                    
                    expect(searchedCategories.count).to(equal(expectedCategories.count))
                    expect(searchedCategories).to(contain(expectedCategories))
                    expect(searchedCategories).toNot(contain(shouldNotContainCategories))
                }
            }
        }
    }
}
