//
//  SearchToolFilterCategoriesRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/4/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Quick
import Nimble

class SearchToolFilterCategoriesRepositoryTests: QuickSpec {
    
    override class func spec() {
     
        describe("User is searching a category in the tools filter categories list.") {
            
            let searchCategoriesRepository = SearchToolFilterCategoriesRepository(
                stringSearcher: StringSearcher()
            )
            
            let lowercasedSingleLetterSearchString: String = "c"
            
            context("When a user inputs a lowercased single letter search string \(lowercasedSingleLetterSearchString)") {
                
                let allCategories: [CategoryFilterDomainModel] = [
                    .category(categoryId: "", translatedName: "Church", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "church", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "food", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "Food", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "soccer", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "soCCer", toolsAvailableText: "")
                ]
                
                it("I expect all categories that contain the lowercased single letter search string \(lowercasedSingleLetterSearchString) ignoring case.") {
                    
                    var searchedCategories: [String] = Array()
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = searchCategoriesRepository
                            .getSearchResultsPublisher(for: lowercasedSingleLetterSearchString, in: allCategories)
                            .sink { (categories: [CategoryFilterDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                searchedCategories = categories.map({$0.primaryText})
                                
                                done()
                            }
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
                
                let allCategories: [CategoryFilterDomainModel] = [
                    .category(categoryId: "", translatedName: "Church", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "church", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "foody", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "Food", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "soccer", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "soCCer", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "Yellow", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "may", toolsAvailableText: "")
                ]
                
                it("I expect all categories that contain the uppercased single letter search string \(uppercasedSingleLetterSearchString) ignoring case.") {
                    
                    var searchedCategories: [String] = Array()
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = searchCategoriesRepository
                            .getSearchResultsPublisher(for: uppercasedSingleLetterSearchString, in: allCategories)
                            .sink { (categories: [CategoryFilterDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                searchedCategories = categories.map({$0.primaryText})
                                
                                done()
                            }
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
                
                let allCategories: [CategoryFilterDomainModel] = [
                    .category(categoryId: "", translatedName: "blAnd", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "land", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "Canned", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "WAND", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "wander", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "pAnda", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "bran", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "Tan", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "Tanned", toolsAvailableText: ""),
                    .category(categoryId: "", translatedName: "sanded", toolsAvailableText: "")
                ]
                
                it("I expect all categories that contain the multi-text search string \(multiTextSearchString) ignoring case.") {
                    
                    var searchedCategories: [String] = Array()
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = searchCategoriesRepository
                            .getSearchResultsPublisher(for: multiTextSearchString, in: allCategories)
                            .sink { (categories: [CategoryFilterDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                searchedCategories = categories.map({$0.primaryText})
                                
                                done()
                            }
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
