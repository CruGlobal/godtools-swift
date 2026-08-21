//
//  ShareToolQRCodeUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 8/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import SwiftData
import RepositorySync

private enum TestToolId {
    static let article: String = "tool-article"
    static let chooseYourOwnAdventure: String = "tool-cyoa"
    static let lesson: String = "tool-lesson"
    static let metaTool: String = "tool-metatool"
    static let tract: String = "tool-tract"
    static let unknownType: String = "tool-unknown-type"
    static let doesNotExist: String = "tool-does-not-exist"
}

private enum TestLanguageId {
    static let english: String = "0"
    static let spanish: String = "1"
    static let doesNotExist: String = "2"
}

struct ShareToolQRCodeUseCaseTests {

    struct ToolFixture {
        let id: String
        let abbreviation: String
        let resourceType: String
    }

    struct ResourceTypeArgument {
        let toolId: String
        let expectedUrl: String
    }

    struct PageNumberArgument {
        let pageNumber: Int
        let expectedUrl: String
    }

    struct ToolLanguageArgument {
        let toolLanguageId: String
        let expectedUrl: String
    }

    struct MissingDataArgument {
        let toolId: String
        let toolLanguageId: String
    }

    private let expectedHost: String = "knowgod.com"

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the share tool QR code.
        When: The QR code url is requested.
        Then: I expect the url host to be knowgod.com.
        """,
        arguments: [
            TestToolId.tract,
            TestToolId.chooseYourOwnAdventure,
            TestToolId.lesson,
            TestToolId.article,
            TestToolId.metaTool,
            TestToolId.unknownType
        ]
    )
    func urlHostIsKnowgodDotCom(toolId: String) throws {

        let useCase: ShareToolQRCodeUseCase = try getUseCase()

        let qrCode: ShareToolQRCodeDomainModel = try useCase.execute(
            toolId: toolId,
            toolLanguageId: TestLanguageId.english,
            pageNumber: 0
        )

        let urlComponents: URLComponents = try #require(URLComponents(string: qrCode.url))

        #expect(urlComponents.scheme == "https")
        #expect(urlComponents.host == expectedHost)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the share tool QR code.
        When: The QR code url is requested for a tool.
        Then: I expect the url path to match the tool's resource type.
        """,
        arguments: [
            ResourceTypeArgument(
                toolId: TestToolId.tract,
                expectedUrl: "https://knowgod.com/en/tool/v1/tract?icid=gtshare"
            ),
            ResourceTypeArgument(
                toolId: TestToolId.chooseYourOwnAdventure,
                expectedUrl: "https://knowgod.com/en/tool/v2/cyoa?icid=gtshare"
            ),
            ResourceTypeArgument(
                toolId: TestToolId.lesson,
                expectedUrl: "https://knowgod.com/en/lesson/lesson?icid=gtshare"
            ),
            ResourceTypeArgument(
                toolId: TestToolId.article,
                expectedUrl: "https://knowgod.com/en/tool/v1/article?icid=gtshare"
            ),
            ResourceTypeArgument(
                toolId: TestToolId.metaTool,
                expectedUrl: "https://knowgod.com/en/tool/v1/metatool?icid=gtshare"
            ),
            ResourceTypeArgument(
                toolId: TestToolId.unknownType,
                expectedUrl: "https://knowgod.com/en/tool/v1/unknowntype?icid=gtshare"
            )
        ]
    )
    func urlPathMatchesTheToolResourceType(argument: ResourceTypeArgument) throws {

        let useCase: ShareToolQRCodeUseCase = try getUseCase()

        let qrCode: ShareToolQRCodeDomainModel = try useCase.execute(
            toolId: argument.toolId,
            toolLanguageId: TestLanguageId.english,
            pageNumber: 0
        )

        #expect(qrCode.url == argument.expectedUrl)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the share tool QR code.
        When: The QR code url is requested for a page number.
        Then: I expect the page number to be included in the url only when it is greater than zero.
        """,
        arguments: [
            PageNumberArgument(
                pageNumber: -1,
                expectedUrl: "https://knowgod.com/en/tool/v1/tract?icid=gtshare"
            ),
            PageNumberArgument(
                pageNumber: 0,
                expectedUrl: "https://knowgod.com/en/tool/v1/tract?icid=gtshare"
            ),
            PageNumberArgument(
                pageNumber: 1,
                expectedUrl: "https://knowgod.com/en/tool/v1/tract/1?icid=gtshare"
            ),
            PageNumberArgument(
                pageNumber: 12,
                expectedUrl: "https://knowgod.com/en/tool/v1/tract/12?icid=gtshare"
            )
        ]
    )
    func pageNumberIsIncludedInTheUrlOnlyWhenGreaterThanZero(argument: PageNumberArgument) throws {

        let useCase: ShareToolQRCodeUseCase = try getUseCase()

        let qrCode: ShareToolQRCodeDomainModel = try useCase.execute(
            toolId: TestToolId.tract,
            toolLanguageId: TestLanguageId.english,
            pageNumber: argument.pageNumber
        )

        #expect(qrCode.url == argument.expectedUrl)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the share tool QR code.
        When: The QR code url is requested for a tool language.
        Then: I expect the url to point at the tool in that language.
        """,
        arguments: [
            ToolLanguageArgument(
                toolLanguageId: TestLanguageId.english,
                expectedUrl: "https://knowgod.com/en/tool/v1/tract?icid=gtshare"
            ),
            ToolLanguageArgument(
                toolLanguageId: TestLanguageId.spanish,
                expectedUrl: "https://knowgod.com/es/tool/v1/tract?icid=gtshare"
            )
        ]
    )
    func urlPointsAtTheToolInTheRequestedToolLanguage(argument: ToolLanguageArgument) throws {

        let useCase: ShareToolQRCodeUseCase = try getUseCase()

        let qrCode: ShareToolQRCodeDomainModel = try useCase.execute(
            toolId: TestToolId.tract,
            toolLanguageId: argument.toolLanguageId,
            pageNumber: 0
        )

        #expect(qrCode.url == argument.expectedUrl)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the share tool QR code.
        When: The QR code url is requested for a tool or tool language that does not exist.
        Then: I expect an error to be thrown.
        """,
        arguments: [
            MissingDataArgument(
                toolId: TestToolId.doesNotExist,
                toolLanguageId: TestLanguageId.english
            ),
            MissingDataArgument(
                toolId: TestToolId.tract,
                toolLanguageId: TestLanguageId.doesNotExist
            ),
            MissingDataArgument(
                toolId: TestToolId.doesNotExist,
                toolLanguageId: TestLanguageId.doesNotExist
            )
        ]
    )
    func errorIsThrownWhenTheToolOrToolLanguageDoesNotExist(argument: MissingDataArgument) throws {

        let useCase: ShareToolQRCodeUseCase = try getUseCase()

        #expect(throws: (any Error).self) {
            try useCase.execute(
                toolId: argument.toolId,
                toolLanguageId: argument.toolLanguageId,
                pageNumber: 0
            )
        }
    }
}

// MARK: - Test Helpers

extension ShareToolQRCodeUseCaseTests {

    @available(iOS 17.4, *)
    private func getUseCase() throws -> ShareToolQRCodeUseCase {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let context: ModelContext = swiftDatabase.openContext()

        context.insertObjects(objects: getSwiftDatabaseObjects())

        try context.saveIfHasChanges()

        let testsDiContainer: TestsDiContainer = TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: swiftDatabase
            )
        )

        return ShareToolQRCodeUseCase(
            getShareToolUrl: GetShareToolUrl(
                resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
                languagesRepository: testsDiContainer.core.dataLayer.getLanguagesRepository()
            )
        )
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any PersistentModel] {

        let languages: [SwiftLanguage] = [
            Self.createLanguage(id: TestLanguageId.english, code: .english),
            Self.createLanguage(id: TestLanguageId.spanish, code: .spanish)
        ]

        let tools: [SwiftResource] = allTools.map { (fixture: ToolFixture) in

            let resource = SwiftResource()
            resource.id = fixture.id
            resource.abbreviation = fixture.abbreviation
            resource.resourceType = fixture.resourceType

            return resource
        }

        return languages + tools
    }

    @available(iOS 17.4, *)
    private static func createLanguage(id: String, code: LanguageCodeDomainModel) -> SwiftLanguage {

        let language = SwiftLanguage()
        language.id = id
        language.code = code.rawValue
        language.name = code.rawValue + " Name"

        return language
    }

    private var allTools: [ToolFixture] {

        return [
            ToolFixture(
                id: TestToolId.article,
                abbreviation: "article",
                resourceType: ResourceType.article.rawValue
            ),
            ToolFixture(
                id: TestToolId.chooseYourOwnAdventure,
                abbreviation: "cyoa",
                resourceType: ResourceType.chooseYourOwnAdventure.rawValue
            ),
            ToolFixture(
                id: TestToolId.lesson,
                abbreviation: "lesson",
                resourceType: ResourceType.lesson.rawValue
            ),
            ToolFixture(
                id: TestToolId.metaTool,
                abbreviation: "metatool",
                resourceType: ResourceType.metaTool.rawValue
            ),
            ToolFixture(
                id: TestToolId.tract,
                abbreviation: "tract",
                resourceType: ResourceType.tract.rawValue
            ),
            ToolFixture(
                id: TestToolId.unknownType,
                abbreviation: "unknowntype",
                resourceType: "some-unrecognized-resource-type"
            )
        ]
    }
}
