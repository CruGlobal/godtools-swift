//
//  ToolDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

final class ToolDownloader {
    
    private let cache: ToolDownloaderCache
    private let languagesRepository: LanguagesRepository
    private let translationsRepository: TranslationsRepository
    private let attachmentsRepository: AttachmentsRepository
    private let articleManifestAemRepository: ArticleManifestAemRepository
    private let getToolDataToDownload: ToolDownloaderGetDataToDownload
    
    init(
        cache: ToolDownloaderCache,
        languagesRepository: LanguagesRepository,
        translationsRepository: TranslationsRepository,
        attachmentsRepository: AttachmentsRepository,
        articleManifestAemRepository: ArticleManifestAemRepository,
        getToolDataToDownload: ToolDownloaderGetDataToDownload
    ) {
        
        self.cache = cache
        self.languagesRepository = languagesRepository
        self.translationsRepository = translationsRepository
        self.attachmentsRepository = attachmentsRepository
        self.articleManifestAemRepository = articleManifestAemRepository
        self.getToolDataToDownload = getToolDataToDownload
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
        return cache
            .persistence
            .observeCollectionChangesPublisher()
    }
    
    @MainActor func observeToolChangesPublisher(toolId: ToolDownloadDataModelId) -> AnyPublisher<ToolDownloadDataModel?, Error> {
        
        let cache: ToolDownloaderCache = self.cache
        
        return cache
            .persistence
            .observeCollectionChangesPublisher()
            .tryMap {
                return try cache.persistence.getDataModel(id: toolId.value)
            }
            .eraseToAnyPublisher()
    }
    
    @MainActor func observeToolsChangesPublisher(toolIds: [ToolDownloadDataModelId]) -> AnyPublisher<[ToolDownloadDataModel], Error> {
        
        let cache: ToolDownloaderCache = self.cache
        
        return cache
            .persistence
            .observeCollectionChangesPublisher()
            .flatMap {
                return AnyPublisher() {
                    let toolIdsArray: [String] = toolIds.map { $0.value }
                    let toolIdsSet = Set(toolIdsArray)
                    
                    return try await cache.persistence.getDataModels(getOption: .objectsByIds(ids: toolIdsSet))
                }
            }
            .eraseToAnyPublisher()
    }
    
    func getToolDownload(id: ToolDownloadDataModelId) -> ToolDownloadDataModel? {
        do {
            return try cache.persistence.getDataModel(id: id.value)
        }
        catch _ {
            return nil
        }
    }
}

// MARK: - Download Tools

extension ToolDownloader {
    
    func downloadToolsPublisher(tools: [DownloadToolData], requestPriority: RequestPriority) -> AnyPublisher<[ToolDownloadDataModel], Error> {
        
        return AnyPublisher() {
            await self.downloadTools(tools: tools, requestPriority: requestPriority)
        }
    }
    
    func downloadTools(tools: [DownloadToolData], requestPriority: RequestPriority) async -> [ToolDownloadDataModel] {
                     
        var initialToolDownloads: [ToolDownloadDataModel] = Array()
        
        for tool in tools {
            
            initialToolDownloads.append(
                ToolDownloadDataModel(
                    toolId: tool.toolId,
                    languages: tool.languages,
                    downloadStarted: Date(),
                    progress: 0,
                    downloadErrorDescription: nil,
                    downloadErrorHttpStatusCode: nil
                )
            )
        }
        
        do {
            
            try await cache.persistence.writeObjects(
                externalObjects: initialToolDownloads
            )
        }
        catch _ {
            
        }
        
        var toolDownloads: [ToolDownloadDataModel] = Array()
        
        await withTaskGroup(of: ToolDownloadDataModel.self) { group in
            
            for tool in tools {
                
                group.addTask {
                    return await self.downloadTool(tool: tool, requestPriority: requestPriority)
                }
            }
            
            for await toolDownload in group {
                toolDownloads.append(toolDownload)
            }
        }
        
        return toolDownloads
    }
    
    private func downloadTool(tool: DownloadToolData, requestPriority: RequestPriority) async -> ToolDownloadDataModel {
                
        let downloadData: ToolDownloaderDataToDownload = getToolDataToDownload.getData(tools: [tool])
        
        let totalNumberOfDownloads: Int = downloadData.nonArticleTranslations.count + downloadData.attachments.count + downloadData.articleTranslations.count
        
        var downloadCount: Int = 0
                
        var toolDownload = ToolDownloadDataModel(
            toolId: tool.toolId,
            languages: tool.languages,
            downloadStarted: Date(),
            progress: 0,
            downloadErrorDescription: nil,
            downloadErrorHttpStatusCode: nil
        )
        
        await reportProgressNonThrowing(toolDownload: &toolDownload, progress: 0, error: nil)
        
        do {
            
            // download non article translations
            try await withThrowingTaskGroup(of: Void.self) { group in
                
                for translation in downloadData.nonArticleTranslations {
                    
                    group.addTask {
                        
                        _ = try await self.translationsRepository.downloadAndCacheTranslationFiles(
                            translation: translation,
                            requestPriority: requestPriority
                        )
                    }
                }
                
                for try await _ in group {
                    await incrementDownloadCountAndReportProgress(
                        toolDownload: &toolDownload,
                        downloadCount: &downloadCount,
                        totalNumberOfDownloads: totalNumberOfDownloads,
                        error: nil
                    )
                }
            }
            
            // download attachments
            try await withThrowingTaskGroup(of: Void.self) { group in
                
                for attachment in downloadData.attachments {
                    
                    group.addTask {
                        
                        _ = try await self.attachmentsRepository.downloadAndCacheAttachmentDataIfNeeded(
                            attachment: attachment,
                            requestPriority: requestPriority
                        )
                    }
                }
                
                for try await _ in group {
                    await incrementDownloadCountAndReportProgress(
                        toolDownload: &toolDownload,
                        downloadCount: &downloadCount,
                        totalNumberOfDownloads: totalNumberOfDownloads,
                        error: nil
                    )
                }
            }
            
            // download article translations (translations and manifests)
            try await withThrowingTaskGroup(of: Void.self) { group in
                
                for translation in downloadData.articleTranslations {
                    
                    guard let languageCode = translation.languageDataModel?.code else {
                        
                        await incrementDownloadCountAndReportProgress(
                            toolDownload: &toolDownload,
                            downloadCount: &downloadCount,
                            totalNumberOfDownloads: totalNumberOfDownloads,
                            error: nil
                        )
                        
                        continue
                    }
                    
                    group.addTask {

                        let translationManifestDataModel = try await self.translationsRepository.getTranslationManifestFromCacheElseRemote(
                            translation: translation,
                            manifestParserType: .manifestOnly,
                            requestPriority: requestPriority,
                            includeRelatedFiles: true,
                            shouldFallbackToLatestDownloadedTranslationIfRemoteFails: false
                        )

                        _ = try await self.articleManifestAemRepository.downloadAndCacheManifestAemUris(
                            manifest: translationManifestDataModel.manifest,
                            translationId: translation.id,
                            languageCode: languageCode,
                            downloadCachePolicy: .ignoreCache,
                            requestPriority: requestPriority
                        )
                    }
                }
                
                for try await _ in group {
                    await incrementDownloadCountAndReportProgress(
                        toolDownload: &toolDownload,
                        downloadCount: &downloadCount,
                        totalNumberOfDownloads: totalNumberOfDownloads,
                        error: nil
                    )
                }
            }
        }
        catch let error {
            
            await incrementDownloadCountAndReportProgress(
                toolDownload: &toolDownload,
                downloadCount: &downloadCount,
                totalNumberOfDownloads: totalNumberOfDownloads,
                error: error
            )
        }
        
        return toolDownload
    }
    
    private func incrementDownloadCountAndReportProgress(toolDownload: inout ToolDownloadDataModel, downloadCount: inout Int, totalNumberOfDownloads: Int, error: Error?) async {
        
        downloadCount = downloadCount + 1
        
        let progress: Double = getProgress(
            downloadCount: downloadCount,
            totalNumberOfDownloads: totalNumberOfDownloads
        )
        
        await reportProgressNonThrowing(toolDownload: &toolDownload, progress: progress, error: error)
    }
    
    private func getProgress(downloadCount: Int, totalNumberOfDownloads: Int) -> Double {
        
        let progress: Double
        
        if downloadCount >= totalNumberOfDownloads {
            progress = 1
        }
        else {
            progress = Double(downloadCount) / Double(totalNumberOfDownloads)
        }
        
        return progress
    }
    
    private func reportProgressNonThrowing(toolDownload: inout ToolDownloadDataModel, progress: Double, error: Error?) async {
                
        toolDownload = toolDownload.copy(
            progress: progress,
            downloadErrorDescription: error?.localizedDescription,
            downloadErrorHttpStatusCode: nil
        )
                
        do {
            
            try await cache.persistence.writeObjects(
                externalObjects: [toolDownload]
            )
        }
        catch _ {
            
        }
    }
}

extension ToolDownloader {
    
    func getDownloadProgressForTools(toolIds: Set<String>) async throws -> Double {
        
        let toolDownloads: [ToolDownloadDataModel] = try await cache.persistence.getDataModels(
            getOption: .objectsByIds(ids: toolIds)
        )
        
        let toolProgress: [Double] = toolDownloads.map { $0.progress }
        
        return toolProgress.getAverage()
    }
}
