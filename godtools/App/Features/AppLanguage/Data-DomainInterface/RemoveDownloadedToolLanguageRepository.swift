//
//  RemoveDownloadedToolLanguageRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 12/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class RemoveDownloadedToolLanguageRepository: RemoveDownloadedToolLanguageRepositoryInterface {
    
    let downloadedLanguagesRepository: DownloadedLanguagesRepository
    
    init(downloadedLanguagesRepository: DownloadedLanguagesRepository) {
        
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
    }
    
    func removeDownloadedToolLanguage(languageId: String) -> AnyPublisher<Bool, Never> {
        
        return downloadedLanguagesRepository.deleteDownloadedLanguagePublisher(languageId: languageId)
            .map { _ in
                
                return true
            }
            .catch { _ in
                
                return Just(false)
            }
            .eraseToAnyPublisher()
    }
}
