//
//  RemoveDownloadedToolLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class RemoveDownloadedToolLanguageUseCase {
    
    private let downloadedLanguagesRepository: DownloadedLanguagesRepository
    
    init(downloadedLanguagesRepository: DownloadedLanguagesRepository) {
        
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
    }
    
    func execute(languageId: String) throws {
        
        try downloadedLanguagesRepository
            .deleteDownloadedLanguage(
                languageId: languageId
            )
    }
}
