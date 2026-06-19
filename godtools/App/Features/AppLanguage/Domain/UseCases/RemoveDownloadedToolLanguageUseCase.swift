//
//  RemoveDownloadedToolLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class RemoveDownloadedToolLanguageUseCase {
    
    private let toolLanguageDownloader: ToolLanguageDownloader
    
    init(toolLanguageDownloader: ToolLanguageDownloader) {
        
        self.toolLanguageDownloader = toolLanguageDownloader
    }
    
    func execute(languageId: String) async throws {
        
        try await toolLanguageDownloader
            .deleteToolLanguageDownload(
                languageId: languageId
            )
    }
}
