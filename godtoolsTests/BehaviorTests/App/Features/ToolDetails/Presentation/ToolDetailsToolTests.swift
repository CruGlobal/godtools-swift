//
//  ToolDetailsToolTests.swift
//  godtoolsTests
//
//  Created by Jason Bennett on 11/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct ToolDetailsToolTests {

    struct LanguagesArgument {
        let primaryLanguage: AppLanguageDomainModel?
        let parallelLanguage: AppLanguageDomainModel?
        let expectedPrimaryLanguage: AppLanguageDomainModel
        let expectedParallelLanguage: AppLanguageDomainModel?
    }

    private let appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value

    @Test(
        """
        Given: User is opening a tool from the tools list with English as their app language.
        When: The tool details are created with a primary and parallel language.
        Then: I expect the primary language to default to my app language, and the parallel language to be dropped when it matches the primary language.
        """,
        arguments: [
            LanguagesArgument(
                primaryLanguage: nil,
                parallelLanguage: nil,
                expectedPrimaryLanguage: LanguageCodeDomainModel.english.value,
                expectedParallelLanguage: nil
            ),
            LanguagesArgument(
                primaryLanguage: nil,
                parallelLanguage: LanguageCodeDomainModel.english.value,
                expectedPrimaryLanguage: LanguageCodeDomainModel.english.value,
                expectedParallelLanguage: nil
            ),
            LanguagesArgument(
                primaryLanguage: nil,
                parallelLanguage: LanguageCodeDomainModel.spanish.value,
                expectedPrimaryLanguage: LanguageCodeDomainModel.english.value,
                expectedParallelLanguage: LanguageCodeDomainModel.spanish.value
            ),
            LanguagesArgument(
                primaryLanguage: LanguageCodeDomainModel.english.value,
                parallelLanguage: LanguageCodeDomainModel.english.value,
                expectedPrimaryLanguage: LanguageCodeDomainModel.english.value,
                expectedParallelLanguage: nil
            ),
            LanguagesArgument(
                primaryLanguage: LanguageCodeDomainModel.spanish.value,
                parallelLanguage: LanguageCodeDomainModel.english.value,
                expectedPrimaryLanguage: LanguageCodeDomainModel.spanish.value,
                expectedParallelLanguage: LanguageCodeDomainModel.english.value
            )
        ]
    )
    func parallelLanguageIsDroppedWhenItMatchesThePrimaryLanguage(argument: LanguagesArgument) {

        let tool = ToolDetailsTool(
            appLanguage: appLanguage,
            toolId: "tool-id",
            primaryLanguage: argument.primaryLanguage,
            parallelLanguage: argument.parallelLanguage,
            selectedLanguageIndex: nil
        )

        #expect(tool.primaryLanguage == argument.expectedPrimaryLanguage)
        #expect(tool.parallelLanguage == argument.expectedParallelLanguage)
    }
}
