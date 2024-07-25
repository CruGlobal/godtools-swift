//
//  SearchLessonFilterLanguagesRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/12/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class SearchLessonFilterLanguagesRepositoryTests: QuickSpec {
    
    override class func spec() {
     
        var cancellables: Set<AnyCancellable> = Set()
        
        describe("User is searching a language in the lesson filter languages list.") {
            
            let searchLessonFilterLanguagesRepository = SearchLessonFilterLanguagesRepository(
                stringSearcher: StringSearcher()
            )
            
            let lowercasedSingleLetterSearchString: String = "c"
            
            context("When a user inputs a lowercased single letter search string \(lowercasedSingleLetterSearchString)") {
                
                let allLanguages: [LessonLanguageFilterDomainModel] = [
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "Church", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "church", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "food", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "Food", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "soccer", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "soCCer", lessonsAvailableText: "")
                ]
                
                it("I expect all languages that contain the lowercased single letter search string \(lowercasedSingleLetterSearchString) ignoring case.") {
                    
                    var searchedLanguages: [String] = Array()
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        searchLessonFilterLanguagesRepository
                            .getSearchResultsPublisher(for: lowercasedSingleLetterSearchString, in: allLanguages)
                            .sink { (languages: [LessonLanguageFilterDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                searchedLanguages = languages.map({$0.translatedName})
                                
                                done()
                            }
                            .store(in: &cancellables)
                    }
                    
                    let expectedLanguages: [String] = ["soccer", "soCCer", "Church", "church"]
                    let shouldNotContainLanguages: [String] = ["food", "Food"]
                    
                    expect(searchedLanguages.count).to(equal(expectedLanguages.count))
                    expect(searchedLanguages).to(contain(expectedLanguages))
                    expect(searchedLanguages).toNot(contain(shouldNotContainLanguages))
                }
            }
            
            let uppercasedSingleLetterSearchString: String = "Y"
            
            context("When a user inputs an uppercased single letter search string \(uppercasedSingleLetterSearchString)") {
                
                let allLanguages: [LessonLanguageFilterDomainModel] = [
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "Church", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "church", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "foody", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "Food", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "soccer", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "soCCer", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "Yellow", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "may", lessonsAvailableText: "")
                ]
                
                it("I expect all languages that contain the uppercased single letter search string \(uppercasedSingleLetterSearchString) ignoring case.") {
                    
                    var searchedLanguages: [String] = Array()
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        searchLessonFilterLanguagesRepository
                            .getSearchResultsPublisher(for: uppercasedSingleLetterSearchString, in: allLanguages)
                            .sink { (languages: [LessonLanguageFilterDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                searchedLanguages = languages.map({$0.translatedName})
                                
                                done()
                            }
                            .store(in: &cancellables)
                    }
                    
                    let expectedLanguages: [String] = ["foody", "Yellow", "may"]
                    let shouldNotContainLanguages: [String] = ["Church", "church", "Food", "soccer", "soCCer"]
                    
                    expect(searchedLanguages.count).to(equal(expectedLanguages.count))
                    expect(searchedLanguages).to(contain(expectedLanguages))
                    expect(searchedLanguages).toNot(contain(shouldNotContainLanguages))
                }
            }
            
            let multiTextSearchString: String = "anD"
            
            context("When a user inputs a multi-text search string \(multiTextSearchString)") {
                
                let allLanguages: [LessonLanguageFilterDomainModel] = [
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "blAnd", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "land", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "Canned", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "WAND", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "wander", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "pAnda", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "bran", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "Tan", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "Tanned", lessonsAvailableText: ""),
                    LessonLanguageFilterDomainModel(languageId: "",  languageName: "", translatedName: "sanded", lessonsAvailableText: "")
                ]
                
                it("I expect all languages that contain the multi-text search string \(multiTextSearchString) ignoring case.") {
                    
                    var searchedLanguages: [String] = Array()
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        searchLessonFilterLanguagesRepository
                            .getSearchResultsPublisher(for: multiTextSearchString, in: allLanguages)
                            .sink { (languages: [LessonLanguageFilterDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                searchedLanguages = languages.map({$0.translatedName})
                                
                                done()
                            }
                            .store(in: &cancellables)
                    }
                    
                    let expectedLanguages: [String] = ["blAnd", "land", "WAND", "wander", "pAnda", "sanded"]
                    let shouldNotContainLanguages: [String] = ["Canned", "bran", "Tan", "Tanned"]
                    
                    expect(searchedLanguages.count).to(equal(expectedLanguages.count))
                    expect(searchedLanguages).to(contain(expectedLanguages))
                    expect(searchedLanguages).toNot(contain(shouldNotContainLanguages))
                }
            }
        }
    }
}
