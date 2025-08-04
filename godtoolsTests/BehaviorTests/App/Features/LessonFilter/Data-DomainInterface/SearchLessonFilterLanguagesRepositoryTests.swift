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
                
                let allLanguages: [LessonFilterLanguageDomainModel] = [
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Church", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "church", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "food", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Food", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "soccer", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "soCCer", lessonsAvailableText: "")
                ]
                
                it("I expect all languages that contain the lowercased single letter search string \(lowercasedSingleLetterSearchString) ignoring case.") {
                    
                    var searchedLanguages: [String] = Array()
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        searchLessonFilterLanguagesRepository
                            .getSearchResultsPublisher(for: lowercasedSingleLetterSearchString, in: allLanguages)
                            .sink { (languages: [LessonFilterLanguageDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                searchedLanguages = languages.map({$0.languageNameTranslatedInAppLanguage})
                                
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
                
                let allLanguages: [LessonFilterLanguageDomainModel] = [
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Church", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "church", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "foody", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Food", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "soccer", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "soCCer", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Yellow", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "may", lessonsAvailableText: "")
                ]
                
                it("I expect all languages that contain the uppercased single letter search string \(uppercasedSingleLetterSearchString) ignoring case.") {
                    
                    var searchedLanguages: [String] = Array()
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        searchLessonFilterLanguagesRepository
                            .getSearchResultsPublisher(for: uppercasedSingleLetterSearchString, in: allLanguages)
                            .sink { (languages: [LessonFilterLanguageDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                searchedLanguages = languages.map({$0.languageNameTranslatedInAppLanguage})
                                
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
                
                let allLanguages: [LessonFilterLanguageDomainModel] = [
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "blAnd", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "land", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Canned", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "WAND", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "wander", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "pAnda", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "bran", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Tan", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Tanned", lessonsAvailableText: ""),
                    LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "sanded", lessonsAvailableText: "")
                ]
                
                it("I expect all languages that contain the multi-text search string \(multiTextSearchString) ignoring case.") {
                    
                    var searchedLanguages: [String] = Array()
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        searchLessonFilterLanguagesRepository
                            .getSearchResultsPublisher(for: multiTextSearchString, in: allLanguages)
                            .sink { (languages: [LessonFilterLanguageDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                searchedLanguages = languages.map({$0.languageNameTranslatedInAppLanguage})
                                
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
