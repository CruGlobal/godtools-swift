//
//  GetShareToolStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetShareToolStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    private let unknownToolId: String = "unknown-tool"
    private let unknownToolLanguageId: String = "unknown-language"

    @Test(
        """
        Given: User is sharing a tool but a share url cannot be generated for the tool.
        When: The share tool strings are requested for an app language.
        Then: The share message is the localized share message and the qr code action title is localized.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedWhenShareUrlCannotBeGenerated(argument: TestArgument) async throws {

        let useCase = try getUseCase()

        let strings: ShareToolStringsDomainModel = useCase.execute(
            toolId: unknownToolId,
            toolLanguageId: unknownToolLanguageId,
            pageNumber: 0,
            appLanguage: argument.appLanguage
        )

        #expect(strings.shareMessage == "\(argument.appLanguage):\(LocalizableStringKeys.tractShareMessage.key)")
        #expect(strings.qrCodeActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.toolScreenShareQrCodeTitle.key)")
    }
}

extension GetShareToolStringsUseCaseTests {

    private func getUseCase() throws -> GetShareToolStringsUseCase {

        let testsDiContainer = try TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                realmDatabase: FakeRealmDatabase.createRealmDatabase()
            )
        )

        let getShareToolUrl = GetShareToolUrl(
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.core.dataLayer.getLanguagesRepository()
        )

        let stringKeys: [LocalizableStringKeys] = [.tractShareMessage, .toolScreenShareQrCodeTitle]

        return GetShareToolStringsUseCase(
            getShareToolUrl: getShareToolUrl,
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
