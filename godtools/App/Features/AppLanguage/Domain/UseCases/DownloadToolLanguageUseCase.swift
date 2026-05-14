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
    
    private let toolLanguageDownloader: ToolLanguageDownloader
    
    init(toolLanguageDownloader: ToolLanguageDownloader) {
        
        self.toolLanguageDownloader = toolLanguageDownloader
    }
    
    @MainActor func execute(languageId: String) -> AnyPublisher<Double, Error> {
        
        Task {
            try await toolLanguageDownloader
                .downloadToolLanguage(languageId: languageId)
        }
        
        return toolLanguageDownloader
            .observeCollectionChanges()
            .tryMap { _ in
                
                let toolLanguageDownload: ToolLanguageDownloadDataModel? = try self.toolLanguageDownloader.getToolLanguageDownload(
                    languageId: languageId
                )
                
                return toolLanguageDownload?.downloadProgress ?? 0
            }
            .eraseToAnyPublisher()
    }
}
