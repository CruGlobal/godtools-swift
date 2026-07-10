//
//  StringSearcherTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 7/21/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct StringSearcherTests {
    
    struct TestArgument {
        let searchTerm: String
        let expectedSearchResults: [FakeStringSearchable]
    }
    
    struct FakeStringSearchable: StringSearchable, Equatable {
        let searchableStrings: [String]
    }
    
    private static let englishSearchable = FakeStringSearchable(searchableStrings: ["English", "English"])
    private static let albanianSearchable = FakeStringSearchable(searchableStrings: ["Albanian", "shqip"])
    private static let amharicSearchable = FakeStringSearchable(searchableStrings: ["Amharic", "አማርኛ"])
    private static let croatianSearchable = FakeStringSearchable(searchableStrings: ["Croatian", "hrvatski"])
    private static let englishBahrainSearchable = FakeStringSearchable(searchableStrings: ["English (Bahrain)", "English (Bahrain)"])
    private static let frenchSearchable = FakeStringSearchable(searchableStrings: ["French", "français"])
    private static let spanishSearchable = FakeStringSearchable(searchableStrings: ["Spanish", "español"])
    
    @Test(
        "Search a list of StringSearchables with a search term string and return case-insensitive matches",
        arguments: [
            TestArgument(searchTerm: "English", expectedSearchResults: [englishSearchable, englishBahrainSearchable]),
            TestArgument(searchTerm: "Bangla", expectedSearchResults: []),
            TestArgument(searchTerm: "SH", expectedSearchResults: [englishSearchable, albanianSearchable, englishBahrainSearchable, spanishSearchable]),
            TestArgument(searchTerm: "french", expectedSearchResults: [frenchSearchable]),
            TestArgument(searchTerm: "ESPAÑOL", expectedSearchResults: [spanishSearchable]),
            TestArgument(searchTerm: "ai", expectedSearchResults: [englishBahrainSearchable, frenchSearchable]),
            TestArgument(searchTerm: "(", expectedSearchResults: [englishBahrainSearchable]),
            TestArgument(searchTerm: "ማርኛ", expectedSearchResults: [amharicSearchable])
        ]
    )
    func stringSearcherTest(argument: TestArgument) {
        
        let stringSearcher: StringSearcher = StringSearcher()
        
        let searchableLanguages: [FakeStringSearchable] = [
            StringSearcherTests.englishSearchable, StringSearcherTests.albanianSearchable, StringSearcherTests.amharicSearchable, StringSearcherTests.croatianSearchable, StringSearcherTests.englishBahrainSearchable, StringSearcherTests.frenchSearchable, StringSearcherTests.spanishSearchable
        ]
        
        let searchResults = stringSearcher.search(for: argument.searchTerm, in: searchableLanguages)
        
        #expect(searchResults == argument.expectedSearchResults)
    }
    
    
    @Test(
        "Searching with an empty string should return original list of StringSearchables",
        arguments: [
            TestArgument(searchTerm: "", expectedSearchResults: [englishSearchable, albanianSearchable, amharicSearchable, croatianSearchable, englishBahrainSearchable, frenchSearchable, spanishSearchable])
            ]
    )
    func emptyStringSearchTest(argument: TestArgument) {
        
        let stringSearcher: StringSearcher = StringSearcher()

        let searchableLanguages: [FakeStringSearchable] = [
            StringSearcherTests.englishSearchable, StringSearcherTests.albanianSearchable, StringSearcherTests.amharicSearchable, StringSearcherTests.croatianSearchable, StringSearcherTests.englishBahrainSearchable, StringSearcherTests.frenchSearchable, StringSearcherTests.spanishSearchable
        ]
        
        let searchResults = stringSearcher.search(for: argument.searchTerm, in: searchableLanguages)
        
        #expect(searchResults == argument.expectedSearchResults)
    }
}
