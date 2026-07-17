//
//  RealmResourcesSHA256FileCacheTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import RealmSwift
import RepositorySync

@Suite(.serialized)
final class RealmResourcesSHA256FileCacheTests {

    private static let attachmentId: String = "attachment_1"
    private static let translationId: String = "translation_1"

    private let fileCache: ResourcesFileCache
    private let realmDatabase: RealmDatabase

    init() throws {
        
        let fileManager = FileManager.default

        fileCache = ResourcesFileCache(
            rootDirectory: FileCache.createTempDirectoryWithDirectoryName(
                directoryName: "tests_realm_resources_sha256_files",
                fileManager: fileManager
            ),
            fileManager: fileManager
        )
        
        try? fileCache.removeRootDirectory()

        realmDatabase = try Self.createOnDiskRealmDatabase()
    }

    deinit {
        try? fileCache.removeRootDirectory()
        _ = try? Realm.deleteFiles(for: realmDatabase.databaseConfig.config)
    }

    // MARK: - Store Attachment File

    @Test
    func storeAttachmentFileStoresFileAtReturnedLocation() async throws {

        try seed(realmObjects: [createAttachment(id: Self.attachmentId)])

        let subject = getSubject()

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

    @Test
    func storeAttachmentFileCreatesSHA256FileRelationshipToAttachment() async throws {

        try seed(realmObjects: [createAttachment(id: Self.attachmentId)])

        let subject = getSubject()

        _ = try await subject.storeAttachmentFile(
            attachmentId: Self.attachmentId,
            fileName: "attachment_sha.png",
            fileData: try #require("data".data(using: .utf8))
        )

        let realm: Realm = try openRefreshedRealm()
        let sha256File: RealmSHA256File = try #require(realm.object(ofType: RealmSHA256File.self, forPrimaryKey: "attachment_sha.png"))

        #expect(sha256File.attachments.map { $0.id } == [Self.attachmentId])
        #expect(sha256File.translations.isEmpty)
    }

    @Test
    func storingAnAttachmentFileThatIsAlreadyRelatedToTheAttachmentPreservesOtherRelationships() async throws {

        try seed(realmObjects: [createAttachment(id: Self.attachmentId), createTranslation(id: Self.translationId)])

        let subject = getSubject()

        let fileName: String = "shared_sha.bin"

        _ = try await subject.storeTranslationFile(
            translationId: Self.translationId,
            fileName: fileName,
            fileData: try #require("data".data(using: .utf8))
        )

        _ = try await subject.storeAttachmentFile(
            attachmentId: Self.attachmentId,
            fileName: fileName,
            fileData: try #require("data".data(using: .utf8))
        )

        _ = try await subject.storeAttachmentFile(
            attachmentId: Self.attachmentId,
            fileName: fileName,
            fileData: try #require("data".data(using: .utf8))
        )

        let realm: Realm = try openRefreshedRealm()
        let sha256File: RealmSHA256File = try #require(realm.object(ofType: RealmSHA256File.self, forPrimaryKey: fileName))

        #expect(sha256File.attachments.map { $0.id } == [Self.attachmentId])
        #expect(sha256File.translations.map { $0.id } == [Self.translationId])
    }

    @Test
    func storeAttachmentFileThrowsWhenAttachmentDoesNotExistInRealm() async throws {

        let subject = getSubject()

        await #expect(throws: (any Error).self) {
            _ = try await subject.storeAttachmentFile(
                attachmentId: "attachment_does_not_exist",
                fileName: "attachment_sha.png",
                fileData: try #require("data".data(using: .utf8))
            )
        }
    }

    // MARK: - Store Translation File

    @Test
    func storeTranslationFileStoresFileAtReturnedLocation() async throws {

        try seed(realmObjects: [createTranslation(id: Self.translationId)])

        let subject = getSubject()

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

    @Test
    func storeTranslationFileCreatesSHA256FileRelationshipToTranslation() async throws {

        try seed(realmObjects: [createTranslation(id: Self.translationId)])

        let subject = getSubject()

        _ = try await subject.storeTranslationFile(
            translationId: Self.translationId,
            fileName: "translation_sha.xml",
            fileData: try #require("data".data(using: .utf8))
        )

        let realm: Realm = try openRefreshedRealm()
        let sha256File: RealmSHA256File = try #require(realm.object(ofType: RealmSHA256File.self, forPrimaryKey: "translation_sha.xml"))

        #expect(sha256File.translations.map { $0.id } == [Self.translationId])
        #expect(sha256File.attachments.isEmpty)
    }

    @Test
    func storeMultipleTranslationFilesForSameTranslationCreatesRelationships() async throws {

        try seed(realmObjects: [createTranslation(id: Self.translationId)])

        let subject = getSubject()

        _ = try await subject.storeTranslationFile(
            translationId: Self.translationId,
            fileName: "translation_manifest.xml",
            fileData: try #require("manifest".data(using: .utf8))
        )

        _ = try await subject.storeTranslationFile(
            translationId: Self.translationId,
            fileName: "translation_page_1.xml",
            fileData: try #require("page 1".data(using: .utf8))
        )

        let realm: Realm = try openRefreshedRealm()
        let manifestFile: RealmSHA256File = try #require(realm.object(ofType: RealmSHA256File.self, forPrimaryKey: "translation_manifest.xml"))
        let pageFile: RealmSHA256File = try #require(realm.object(ofType: RealmSHA256File.self, forPrimaryKey: "translation_page_1.xml"))

        #expect(manifestFile.translations.map { $0.id } == [Self.translationId])
        #expect(pageFile.translations.map { $0.id } == [Self.translationId])
    }

    @Test
    func storingATranslationFileThatIsAlreadyRelatedToTheTranslationPreservesOtherRelationships() async throws {

        try seed(realmObjects: [createTranslation(id: Self.translationId), createAttachment(id: Self.attachmentId)])

        let subject = getSubject()

        let fileName: String = "shared_sha.bin"

        _ = try await subject.storeAttachmentFile(
            attachmentId: Self.attachmentId,
            fileName: fileName,
            fileData: try #require("data".data(using: .utf8))
        )

        _ = try await subject.storeTranslationFile(
            translationId: Self.translationId,
            fileName: fileName,
            fileData: try #require("data".data(using: .utf8))
        )

        _ = try await subject.storeTranslationFile(
            translationId: Self.translationId,
            fileName: fileName,
            fileData: try #require("data".data(using: .utf8))
        )

        let realm: Realm = try openRefreshedRealm()
        let sha256File: RealmSHA256File = try #require(realm.object(ofType: RealmSHA256File.self, forPrimaryKey: fileName))

        #expect(sha256File.translations.map { $0.id } == [Self.translationId])
        #expect(sha256File.attachments.map { $0.id } == [Self.attachmentId])
    }

    @Test
    func storeTranslationFileThrowsWhenTranslationDoesNotExistInRealm() async throws {

        let subject = getSubject()

        await #expect(throws: (any Error).self) {
            _ = try await subject.storeTranslationFile(
                translationId: "translation_does_not_exist",
                fileName: "translation_sha.xml",
                fileData: try #require("data".data(using: .utf8))
            )
        }
    }

    // MARK: - Get File Exists

    @Test
    func getFileExistsReturnsFalseWhenFileWasNotStored() async throws {

        let subject = getSubject()

        let fileExists: Bool = try await subject.getFileExists(
            location: FileCacheLocation(relativeUrlString: "not_stored.png")
        )

        #expect(fileExists == false)
    }

    // MARK: - Deleting Unused Files

    @Test
    func storingAFileDeletesUnusedSHA256FilesAndTheirStoredFiles() async throws {

        let orphanLocation = FileCacheLocation(relativeUrlString: "orphan_sha.png")

        _ = try fileCache.storeFile(
            location: orphanLocation,
            data: try #require("orphan data".data(using: .utf8))
        )

        let orphanSHA256File = RealmSHA256File()
        orphanSHA256File.sha256WithPathExtension = "orphan_sha.png"

        try seed(realmObjects: [createAttachment(id: Self.attachmentId), orphanSHA256File])

        let subject = getSubject()

        let orphanExistsBeforeStore: Bool = try await subject.getFileExists(location: orphanLocation)

        let storedLocation: FileCacheLocation = try await subject.storeAttachmentFile(
            attachmentId: Self.attachmentId,
            fileName: "attachment_sha.png",
            fileData: try #require("data".data(using: .utf8))
        )

        let orphanExistsAfterStore: Bool = try await subject.getFileExists(location: orphanLocation)
        let storedFileExists: Bool = try await subject.getFileExists(location: storedLocation)

        let realm: Realm = try openRefreshedRealm()
        let orphanSHA256FileAfterStore = realm.object(ofType: RealmSHA256File.self, forPrimaryKey: "orphan_sha.png")

        #expect(orphanExistsBeforeStore == true)
        #expect(orphanExistsAfterStore == false)
        #expect(storedFileExists == true)
        #expect(orphanSHA256FileAfterStore == nil)
    }
}

// MARK: - Test Helpers

extension RealmResourcesSHA256FileCacheTests {

    private static func createOnDiskRealmDatabase() throws -> RealmDatabase {

        let migrationBlock: MigrationBlock = { @Sendable (_: Migration, _: UInt64) in }

        let databaseConfig = try RealmDatabaseConfig(
            fileName: "godtools_tests_realm_" + UUID().uuidString,
            schemaVersion: RealmProductionConfig.schemaVersion,
            migrationBlock: migrationBlock
        )

        return RealmDatabase(databaseConfig: databaseConfig)
    }

    private func seed(realmObjects: [IdentifiableRealmObject]) throws {

        let realm: Realm = try realmDatabase.openRealm()

        try realm.write {
            realm.add(realmObjects, update: .modified)
        }
    }

    private func openRefreshedRealm() throws -> Realm {

        let realm: Realm = try realmDatabase.openRealm()
        realm.refresh()

        return realm
    }

    private func getSubject() -> RealmResourcesSHA256FileCache {

        return RealmResourcesSHA256FileCache(
            fileCache: fileCache,
            realmDatabase: realmDatabase,
            realmDataWrite: RealmDataWrite(config: realmDatabase.databaseConfig.config)
        )
    }

    private func createAttachment(id: String) -> RealmAttachment {

        let attachment = RealmAttachment()
        attachment.id = id

        return attachment
    }

    private func createTranslation(id: String) -> RealmTranslation {

        let translation = RealmTranslation()
        translation.id = id

        return translation
    }
}
