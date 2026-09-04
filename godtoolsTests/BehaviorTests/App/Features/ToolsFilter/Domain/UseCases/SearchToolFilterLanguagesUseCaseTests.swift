//
//  SearchToolFilterLanguagesUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/28/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct SearchToolFilterLanguagesUseCaseTests {

    struct TestArgument {
        let searchString: String
        let expectedLanguages: [String]
    }

    @Test(
        """
        Given: User is searching a language in the tools filter languages list.
        When: User inputs a search string.
        Then: I expect to see all languages that contain the search string ignoring case.
        """,
        arguments: [
            TestArgument(
                searchString: "ES",
                expectedLanguages: ["Spanish", "Portuguese", "Vietnamese"]
            ),
            TestArgument(
                searchString: "czech",
                expectedLanguages: ["Czech"]
            ),
            TestArgument(
                searchString: "AfriKAAns",
                expectedLanguages: ["Afrikaans"]
            )
        ]
    )
    func showsLanguagesContainingSearchStringIgnoringCase(argument: TestArgument) {

        let searchToolFilterLanguagesUseCase = getSearchToolFilterLanguagesUseCase()

        let searchedLanguages: [ToolFilterLanguageDomainModel] = searchToolFilterLanguagesUseCase
            .execute(searchText: argument.searchString, toolFilterLanguages: allLanguages)

        #expect(argument.expectedLanguages.elementsEqual(searchedLanguages.map({ $0.languageNamePair.nameInAppLanguage })))
    }

    @Test(
        """
        Given: User is searching a language in the tools filter languages list.
        When: User inputs a search string matching a language name translated in its own language.
        Then: I expect to see that language even though its name translated in my app language does not match.
        """,
        arguments: [
            TestArgument(
                searchString: "fran",
                expectedLanguages: ["French"]
            ),
            TestArgument(
                searchString: "čeština",
                expectedLanguages: ["Czech"]
            ),
            TestArgument(
                searchString: "deutsch",
                expectedLanguages: ["German"]
            )
        ]
    )
    func matchesLanguagesByNameTranslatedInTheirOwnLanguage(argument: TestArgument) {

        let searchToolFilterLanguagesUseCase = getSearchToolFilterLanguagesUseCase()

        let searchedLanguages: [ToolFilterLanguageDomainModel] = searchToolFilterLanguagesUseCase
            .execute(searchText: argument.searchString, toolFilterLanguages: allLanguages)

        #expect(argument.expectedLanguages.elementsEqual(searchedLanguages.map({ $0.languageNamePair.nameInAppLanguage })))
    }

    @Test(
        """
        Given: User is searching a language in the tools filter languages list.
        When: User inputs a search string matching a language name translated in my app language.
        Then: I expect to see that language even though its name translated in its own language does not match.
        """,
        arguments: [
            TestArgument(
                searchString: "span",
                expectedLanguages: ["Spanish"]
            ),
            TestArgument(
                searchString: "dutch",
                expectedLanguages: ["Dutch"]
            ),
            TestArgument(
                searchString: "russian",
                expectedLanguages: ["Russian"]
            )
        ]
    )
    func matchesLanguagesByNameTranslatedInMyAppLanguage(argument: TestArgument) {

        let searchToolFilterLanguagesUseCase = getSearchToolFilterLanguagesUseCase()

        let searchedLanguages: [ToolFilterLanguageDomainModel] = searchToolFilterLanguagesUseCase
            .execute(searchText: argument.searchString, toolFilterLanguages: allLanguages)

        #expect(argument.expectedLanguages.elementsEqual(searchedLanguages.map({ $0.languageNamePair.nameInAppLanguage })))
    }

    @Test(
        """
        Given: User is searching a language in the tools filter languages list.
        When: User inputs a search string matching a language that has no name translated in its own language.
        Then: I expect to see that language matched by its name translated in my app language.
        """,
        arguments: [
            TestArgument(
                searchString: "Any",
                expectedLanguages: ["Any language"]
            ),
            TestArgument(
                searchString: "unknown",
                expectedLanguages: ["Unknown language"]
            )
        ]
    )
    func matchesLanguagesWithoutANameTranslatedInTheirOwnLanguage(argument: TestArgument) {

        let searchToolFilterLanguagesUseCase = getSearchToolFilterLanguagesUseCase()

        let searchedLanguages: [ToolFilterLanguageDomainModel] = searchToolFilterLanguagesUseCase
            .execute(searchText: argument.searchString, toolFilterLanguages: allLanguages)

        #expect(argument.expectedLanguages.elementsEqual(searchedLanguages.map({ $0.languageNamePair.nameInAppLanguage })))
    }

    @Test(
        """
        Given: User is searching a language in the tools filter languages list.
        When: The search string is empty.
        Then: I expect to see all languages in their original order.
        """
    )
    func showsAllLanguagesWhenSearchStringIsEmpty() {

        let searchToolFilterLanguagesUseCase = getSearchToolFilterLanguagesUseCase()

        let searchedLanguages: [ToolFilterLanguageDomainModel] = searchToolFilterLanguagesUseCase
            .execute(searchText: "", toolFilterLanguages: allLanguages)

        #expect(searchedLanguages.map({ $0.languageNamePair.nameInAppLanguage }) == allLanguages.map({ $0.languageNamePair.nameInAppLanguage }))
    }

    @Test(
        """
        Given: User is searching a language in the tools filter languages list.
        When: User inputs a search string that no language contains.
        Then: I expect to see no languages.
        """
    )
    func showsNoLanguagesWhenNoLanguageContainsTheSearchString() {

        let searchToolFilterLanguagesUseCase = getSearchToolFilterLanguagesUseCase()

        let searchedLanguages: [ToolFilterLanguageDomainModel] = searchToolFilterLanguagesUseCase
            .execute(searchText: "zzz", toolFilterLanguages: allLanguages)

        #expect(searchedLanguages.isEmpty)
    }
}

// MARK: - Test Helpers

extension SearchToolFilterLanguagesUseCaseTests {

    private func getSearchToolFilterLanguagesUseCase() -> SearchToolFilterLanguagesUseCase {
        return SearchToolFilterLanguagesUseCase(stringSearcher: StringSearcher())
    }

    private var allLanguages: [ToolFilterLanguageDomainModel] {

        return [
            ToolFilterLanguageDomainModel.createAnyLanguage(
                nameInAppLanguage: "Any language",
                toolsAvailableText: "",
                toolsAvailableCount: 0
            ),
            Self.createLanguage(id: "af", nameInOwnLanguage: "Afrikaans", nameInAppLanguage: "Afrikaans"),
            Self.createLanguage(id: "cs", nameInOwnLanguage: "čeština", nameInAppLanguage: "Czech"),
            Self.createLanguage(id: "de", nameInOwnLanguage: "Deutsch", nameInAppLanguage: "German"),
            Self.createLanguage(id: "en", nameInOwnLanguage: "English", nameInAppLanguage: "English"),
            Self.createLanguage(id: "es", nameInOwnLanguage: "Español", nameInAppLanguage: "Spanish"),
            Self.createLanguage(id: "fr", nameInOwnLanguage: "Français", nameInAppLanguage: "French"),
            Self.createLanguage(id: "nl", nameInOwnLanguage: "Nederlands", nameInAppLanguage: "Dutch"),
            Self.createLanguage(id: "pt", nameInOwnLanguage: "Português", nameInAppLanguage: "Portuguese"),
            Self.createLanguage(id: "ru", nameInOwnLanguage: "Русский", nameInAppLanguage: "Russian"),
            Self.createLanguage(id: "vi", nameInOwnLanguage: "Tiếng Việt", nameInAppLanguage: "Vietnamese"),
            Self.createLanguage(id: "xx", nameInOwnLanguage: "", nameInAppLanguage: "Unknown language")
        ]
    }

    private static func createLanguage(id: String, nameInOwnLanguage: String, nameInAppLanguage: String) -> ToolFilterLanguageDomainModel {

        return ToolFilterLanguageDomainModel.createLanguage(
            languageId: id,
            languageNamePair: TranslatedLanguageNamePairDomainModel(
                nameInOwnLanguage: nameInOwnLanguage,
                nameInAppLanguage: nameInAppLanguage
            ),
            toolsAvailableText: "",
            toolsAvailableCount: 0
        )
    }
}
