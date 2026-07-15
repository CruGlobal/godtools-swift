//
//  ResourcesSHA256FileCacheTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import SwiftData
import RepositorySync

@Suite(.serialized)
final class ResourcesSHA256FileCacheTests {

    private static let attachmentId: String = "attachment_1"
    private static let translationId: String = "translation_1"

    private let fileCache: ResourcesFileCache

    init() throws {

        fileCache = ResourcesFileCache()
        try? fileCache.removeRootDirectory()
    }

    deinit {
        try? fileCache.removeRootDirectory()
    }

    // MARK: - Store Attachment File

    @available(iOS 17.4, *)
    @Test
    func storeAttachmentFileStoresFileAtReturnedLocation() async throws {

        let container: ModelContainer = try createContainer()

        try seed(container: container, objects: [createAttachment(id: Self.attachmentId)])

        let subject = getSubject(container: container)

        let fileData: Data = try #require("attachment file contents".data(using: .utf8))

        let location: FileCacheLocation = try await subject.storeAttachmentFile(
            attachmentId: Self.attachmentId,
            fileName: "attachment_sha.png",
            fileData: fileData
        )

        let fileExists: Bool = try await subject.getFileExists(location: location)
        let storedData: Data? = try await subject.getData(location: location)

        #expect(location.relativeUrlString == "attachment_sha.png")
        #expect(fileExists == true)
        #expect(storedData == fileData)
    }

    @available(iOS 17.4, *)
    @Test
    func storeAttachmentFileCreatesSHA256FileRelationshipToAttachment() async throws {

        let container: ModelContainer = try createContainer()

        try seed(container: container, objects: [createAttachment(id: Self.attachmentId)])

        let subject = getSubject(container: container)

        _ = try await subject.storeAttachmentFile(
            attachmentId: Self.attachmentId,
            fileName: "attachment_sha.png",
            fileData: try #require("data".data(using: .utf8))
        )

        let sha256File: SwiftSHA256File = try #require(fetchSHA256File(container: container, sha256WithPathExtension: "attachment_sha.png"))

        #expect(sha256File.attachments.map { $0.id } == [Self.attachmentId])
        #expect(sha256File.translations.isEmpty)
    }

    @available(iOS 17.4, *)
    @Test
    func storeAttachmentFileThrowsWhenAttachmentDoesNotExistInDatabase() async throws {

        let container: ModelContainer = try createContainer()

        let subject = getSubject(container: container)

        await #expect(throws: (any Error).self) {
            _ = try await subject.storeAttachmentFile(
                attachmentId: "attachment_does_not_exist",
                fileName: "attachment_sha.png",
                fileData: try #require("data".data(using: .utf8))
            )
        }
    }

    // MARK: - Store Translation File

    @available(iOS 17.4, *)
    @Test
    func storeTranslationFileStoresFileAtReturnedLocation() async throws {

        let container: ModelContainer = try createContainer()

        try seed(container: container, objects: [createTranslation(id: Self.translationId)])

        let subject = getSubject(container: container)

        let fileData: Data = try #require("translation file contents".data(using: .utf8))

        let location: FileCacheLocation = try await subject.storeTranslationFile(
            translationId: Self.translationId,
            fileName: "translation_sha.xml",
            fileData: fileData
        )

        let fileExists: Bool = try await subject.getFileExists(location: location)
        let storedData: Data? = try await subject.getData(location: location)

        #expect(location.relativeUrlString == "translation_sha.xml")
        #expect(fileExists == true)
        #expect(storedData == fileData)
    }

    @available(iOS 17.4, *)
    @Test
    func storeTranslationFileCreatesSHA256FileRelationshipToTranslation() async throws {

        let container: ModelContainer = try createContainer()

        try seed(container: container, objects: [createTranslation(id: Self.translationId)])

        let subject = getSubject(container: container)

        _ = try await subject.storeTranslationFile(
            translationId: Self.translationId,
            fileName: "translation_sha.xml",
            fileData: try #require("data".data(using: .utf8))
        )

        let sha256File: SwiftSHA256File = try #require(fetchSHA256File(container: container, sha256WithPathExtension: "translation_sha.xml"))

        #expect(sha256File.translations.map { $0.id } == [Self.translationId])
        #expect(sha256File.attachments.isEmpty)
    }

    @available(iOS 17.4, *)
    @Test
    func storeTranslationFileThrowsWhenTranslationDoesNotExistInDatabase() async throws {

        let container: ModelContainer = try createContainer()

        let subject = getSubject(container: container)

        await #expect(throws: (any Error).self) {
            _ = try await subject.storeTranslationFile(
                translationId: "translation_does_not_exist",
                fileName: "translation_sha.xml",
                fileData: try #require("data".data(using: .utf8))
            )
        }
    }

    // MARK: - Get File Exists

    @available(iOS 17.4, *)
    @Test
    func getFileExistsReturnsFalseWhenFileWasNotStored() async throws {

        let container: ModelContainer = try createContainer()

        let subject = getSubject(container: container)

        let fileExists: Bool = try await subject.getFileExists(
            location: FileCacheLocation(relativeUrlString: "not_stored.png")
        )

        #expect(fileExists == false)
    }

    // MARK: - Deleting Unused Files

    @available(iOS 17.4, *)
    @Test
    func storingAFileDeletesUnusedSHA256FilesAndTheirStoredFiles() async throws {

        let container: ModelContainer = try createContainer()

        let orphanLocation = FileCacheLocation(relativeUrlString: "orphan_sha.png")

        _ = try fileCache.storeFile(
            location: orphanLocation,
            data: try #require("orphan data".data(using: .utf8))
        )

        let orphanSHA256File = SwiftSHA256File()
        orphanSHA256File.sha256WithPathExtension = "orphan_sha.png"
        orphanSHA256File.id = "orphan_sha.png"

        try seed(container: container, objects: [createAttachment(id: Self.attachmentId), orphanSHA256File])

        let subject = getSubject(container: container)

        let orphanExistsBeforeStore: Bool = try await subject.getFileExists(location: orphanLocation)

        let storedLocation: FileCacheLocation = try await subject.storeAttachmentFile(
            attachmentId: Self.attachmentId,
            fileName: "attachment_sha.png",
            fileData: try #require("data".data(using: .utf8))
        )

        let orphanExistsAfterStore: Bool = try await subject.getFileExists(location: orphanLocation)
        let storedFileExists: Bool = try await subject.getFileExists(location: storedLocation)

        let orphanSHA256FileAfterStore: SwiftSHA256File? = fetchSHA256File(container: container, sha256WithPathExtension: "orphan_sha.png")

        #expect(orphanExistsBeforeStore == true)
        #expect(orphanExistsAfterStore == false)
        #expect(storedFileExists == true)
        #expect(orphanSHA256FileAfterStore == nil)
    }
}

// MARK: - Test Helpers

extension ResourcesSHA256FileCacheTests {

    @available(iOS 17.4, *)
    private func createContainer() throws -> ModelContainer {

        return try SwiftDataContainer.createInMemoryContainer(
            schema: Schema(versionedSchema: LatestProductionSwiftDataSchema.self)
        ).modelContainer
    }

    @available(iOS 17.4, *)
    private func seed(container: ModelContainer, objects: [any PersistentModel]) throws {

        let context = ModelContext(container)

        for object in objects {
            context.insert(object)
        }

        try context.save()
    }

    @available(iOS 17.4, *)
    private func fetchSHA256File(container: ModelContainer, sha256WithPathExtension: String) -> SwiftSHA256File? {

        let context = ModelContext(container)

        let descriptor = FetchDescriptor<SwiftSHA256File>(
            predicate: #Predicate { object in
                object.sha256WithPathExtension == sha256WithPathExtension
            }
        )

        return try? context.fetch(descriptor).first
    }

    @available(iOS 17.4, *)
    private func getSubject(container: ModelContainer) -> ResourcesSHA256FileCache {

        return ResourcesSHA256FileCache(
            container: container,
            fileCache: fileCache
        )
    }

    @available(iOS 17.4, *)
    private func createAttachment(id: String) -> SwiftAttachment {

        let attachment = SwiftAttachment()
        attachment.id = id

        return attachment
    }

    @available(iOS 17.4, *)
    private func createTranslation(id: String) -> SwiftTranslation {

        let translation = SwiftTranslation()
        translation.id = id

        return translation
    }
}
