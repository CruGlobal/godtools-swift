//
//  GetDownloadToolLanguageProgressUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class GetDownloadToolLanguageProgressUseCase {
    
    private let getProgress: GetDownloadToolLanguageProgressInterface
    
    init(getProgress: GetDownloadToolLanguageProgressInterface) {
        
        self.getProgress = getProgress
    }
    
    func getProgressPublisher(languageId: String) -> AnyPublisher<DownloadToolLanguageProgressDomainModel, Never> {
        
        return getProgress
            .getProgressPublisher(languageId: languageId)
    }
}
