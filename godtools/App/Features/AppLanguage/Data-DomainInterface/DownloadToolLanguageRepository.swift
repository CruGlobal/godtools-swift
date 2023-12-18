//
//  DownloadToolLanguageRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 12/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class DownloadToolLanguageRepository: DownloadToolLanguageRepositoryInterface {
    
    let downloadedLanguagesRepository: DownloadedLanguagesRepository
    
    init(downloadedLanguagesRepository: DownloadedLanguagesRepository) {
        
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
    }
    
    func downloadToolLanguage(languageId: String) -> AnyPublisher<Bool, Never> {
        
        // TODO: - actually perform download
        return Future() { promise in
            
            var progress: Double = 0
            self.downloadedLanguagesRepository.storeDownloadedLanguage(languageId: languageId, downloadProgress: progress)
            
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                progress += 0.1
                
                self.downloadedLanguagesRepository.storeDownloadedLanguage(languageId: languageId, downloadProgress: progress)
                
                if progress > 1 {
                    timer.invalidate()
                    
                    promise(.success(true))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
