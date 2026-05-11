//
//  DownloadToolLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class DownloadToolLanguageUseCase {
    
    private let downloadedLanguagesRepository: DownloadedLanguagesRepository
    private let resourcesRepository: ResourcesRepository
    private let toolLanguageDownloader: ToolLanguageDownloader
    
    init(downloadedLanguagesRepository: DownloadedLanguagesRepository, resourcesRepository: ResourcesRepository, toolLanguageDownloader: ToolLanguageDownloader) {
        
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
        self.resourcesRepository = resourcesRepository
        self.toolLanguageDownloader = toolLanguageDownloader
    }
    
    func execute(languageId: String) async throws -> AsyncThrowingStream<Double, Error> {
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    
                    for try await dataModel in try toolLanguageDownloader.downloadToolLanguage(languageId: languageId) {
                        
                        let downloadComplete: Bool = dataModel.progress >= 1
                        
                        if downloadComplete {
                            
                            _ = try await downloadedLanguagesRepository
                                .storeDownloadedLanguage(
                                    languageId: languageId,
                                    downloadComplete: true
                                )
                        }
                        
                        continuation.yield(dataModel.progress)
                    }
                    
                    continuation.finish()
                }
                catch let error {
                    
                    try downloadedLanguagesRepository.deleteDownloadedLanguage(
                        languageId: languageId
                    )
                    
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
