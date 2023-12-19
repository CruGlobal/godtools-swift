//
//  RemoveDownloadedToolLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class RemoveDownloadedToolLanguageUseCase {
    
    private let removeDownloadedToolLanguageRepository: RemoveDownloadedToolLanguageRepositoryInterface
    
    init(removeDownloadedToolLanguageRepository: RemoveDownloadedToolLanguageRepositoryInterface) {
        
        self.removeDownloadedToolLanguageRepository = removeDownloadedToolLanguageRepository
    }
    
    func removeDownloadedToolLanguage(_ appLanguage: AppLanguageDomainModel) -> AnyPublisher<Bool, Never> {
        
        return removeDownloadedToolLanguageRepository.removeDownloadedToolLanguage(languageId: appLanguage)
    }
}
