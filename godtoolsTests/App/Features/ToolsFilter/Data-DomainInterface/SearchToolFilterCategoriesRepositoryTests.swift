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
                
                let allCategories: [CategoryFilterDomainModelInterface] = [
                    CategoryFilterDomainModel(categoryId: "", translatedName: "Church", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "church", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "food", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "Food", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "soccer", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "soCCer", toolsAvailableText: "")
                ]
                
                it("I expect all categories that contain the lowercased single letter search string \(lowercasedSingleLetterSearchString) ignoring case.") {
                    
                    var searchedCategories: [String] = Array()
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        searchCategoriesRepository
                            .getSearchResultsPublisher(for: lowercasedSingleLetterSearchString, in: allCategories)
                            .sink { (categories: [CategoryFilterDomainModelInterface]) in
                                
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
                
                let allCategories: [CategoryFilterDomainModelInterface] = [
                    CategoryFilterDomainModel(categoryId: "", translatedName: "Church", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "church", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "foody", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "Food", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "soccer", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "soCCer", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "Yellow", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "may", toolsAvailableText: "")
                ]
                
                it("I expect all categories that contain the uppercased single letter search string \(uppercasedSingleLetterSearchString) ignoring case.") {
                    
                    var searchedCategories: [String] = Array()
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        searchCategoriesRepository
                            .getSearchResultsPublisher(for: uppercasedSingleLetterSearchString, in: allCategories)
                            .sink { (categories: [CategoryFilterDomainModelInterface]) in
                                
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
                
                let allCategories: [CategoryFilterDomainModelInterface] = [
                    CategoryFilterDomainModel(categoryId: "", translatedName: "blAnd", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "land", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "Canned", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "WAND", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "wander", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "pAnda", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "bran", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "Tan", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "Tanned", toolsAvailableText: ""),
                    CategoryFilterDomainModel(categoryId: "", translatedName: "sanded", toolsAvailableText: "")
                ]
                
                it("I expect all categories that contain the multi-text search string \(multiTextSearchString) ignoring case.") {
                    
                    var searchedCategories: [String] = Array()
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        searchCategoriesRepository
                            .getSearchResultsPublisher(for: multiTextSearchString, in: allCategories)
                            .sink { (categories: [CategoryFilterDomainModelInterface]) in
                                
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
