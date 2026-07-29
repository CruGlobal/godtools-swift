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
    func showsLanguagesContainingSearchStringIgnoringCase(argument: TestArgument) async {

        let searchToolFilterLanguagesUseCase = getSearchToolFilterLanguagesUseCase()

        let searchedLanguages: [ToolFilterLanguageDomainModel] = await searchToolFilterLanguagesUseCase
            .execute(searchText: argument.searchString, toolFilterLanguages: allLanguages)

        #expect(argument.expectedLanguages.elementsEqual(searchedLanguages.map({ $0.languageNameTranslatedInAppLanguage })))
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
    func matchesLanguagesByNameTranslatedInTheirOwnLanguage(argument: TestArgument) async {

        let searchToolFilterLanguagesUseCase = getSearchToolFilterLanguagesUseCase()

        let searchedLanguages: [ToolFilterLanguageDomainModel] = await searchToolFilterLanguagesUseCase
            .execute(searchText: argument.searchString, toolFilterLanguages: allLanguages)

        #expect(argument.expectedLanguages.elementsEqual(searchedLanguages.map({ $0.languageNameTranslatedInAppLanguage })))
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
    func matchesLanguagesByNameTranslatedInMyAppLanguage(argument: TestArgument) async {

        let searchToolFilterLanguagesUseCase = getSearchToolFilterLanguagesUseCase()

        let searchedLanguages: [ToolFilterLanguageDomainModel] = await searchToolFilterLanguagesUseCase
            .execute(searchText: argument.searchString, toolFilterLanguages: allLanguages)

        #expect(argument.expectedLanguages.elementsEqual(searchedLanguages.map({ $0.languageNameTranslatedInAppLanguage })))
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
    func matchesLanguagesWithoutANameTranslatedInTheirOwnLanguage(argument: TestArgument) async {

        let searchToolFilterLanguagesUseCase = getSearchToolFilterLanguagesUseCase()

        let searchedLanguages: [ToolFilterLanguageDomainModel] = await searchToolFilterLanguagesUseCase
            .execute(searchText: argument.searchString, toolFilterLanguages: allLanguages)

        #expect(argument.expectedLanguages.elementsEqual(searchedLanguages.map({ $0.languageNameTranslatedInAppLanguage })))
    }

    @Test(
        """
        Given: User is searching a language in the tools filter languages list.
        When: The search string is empty.
        Then: I expect to see all languages in their original order.
        """
    )
    func showsAllLanguagesWhenSearchStringIsEmpty() async {

        let searchToolFilterLanguagesUseCase = getSearchToolFilterLanguagesUseCase()

        let searchedLanguages: [ToolFilterLanguageDomainModel] = await searchToolFilterLanguagesUseCase
            .execute(searchText: "", toolFilterLanguages: allLanguages)

        #expect(searchedLanguages.map({ $0.languageNameTranslatedInAppLanguage }) == allLanguages.map({ $0.languageNameTranslatedInAppLanguage }))
    }

    @Test(
        """
        Given: User is searching a language in the tools filter languages list.
        When: User inputs a search string that no language contains.
        Then: I expect to see no languages.
        """
    )
    func showsNoLanguagesWhenNoLanguageContainsTheSearchString() async {

        let searchToolFilterLanguagesUseCase = getSearchToolFilterLanguagesUseCase()

        let searchedLanguages: [ToolFilterLanguageDomainModel] = await searchToolFilterLanguagesUseCase
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
                languageNameTranslatedInAppLanguage: "Any language",
                toolsAvailable: "",
                numberOfToolsAvailable: 0
            ),
            Self.createLanguage(id: "af", languageName: "Afrikaans", languageNameTranslatedInAppLanguage: "Afrikaans"),
            Self.createLanguage(id: "cs", languageName: "čeština", languageNameTranslatedInAppLanguage: "Czech"),
            Self.createLanguage(id: "de", languageName: "Deutsch", languageNameTranslatedInAppLanguage: "German"),
            Self.createLanguage(id: "en", languageName: "English", languageNameTranslatedInAppLanguage: "English"),
            Self.createLanguage(id: "es", languageName: "Español", languageNameTranslatedInAppLanguage: "Spanish"),
            Self.createLanguage(id: "fr", languageName: "Français", languageNameTranslatedInAppLanguage: "French"),
            Self.createLanguage(id: "nl", languageName: "Nederlands", languageNameTranslatedInAppLanguage: "Dutch"),
            Self.createLanguage(id: "pt", languageName: "Português", languageNameTranslatedInAppLanguage: "Portuguese"),
            Self.createLanguage(id: "ru", languageName: "Русский", languageNameTranslatedInAppLanguage: "Russian"),
            Self.createLanguage(id: "vi", languageName: "Tiếng Việt", languageNameTranslatedInAppLanguage: "Vietnamese"),
            Self.createLanguage(id: "xx", languageName: "", languageNameTranslatedInAppLanguage: "Unknown language")
        ]
    }

    private static func createLanguage(id: String, languageName: String, languageNameTranslatedInAppLanguage: String) -> ToolFilterLanguageDomainModel {

        return ToolFilterLanguageDomainModel.createLanguage(
            id: id,
            languageName: languageName,
            languageNameTranslatedInAppLanguage: languageNameTranslatedInAppLanguage,
            toolsAvailable: "",
            numberOfToolsAvailable: 0
        )
    }
}
