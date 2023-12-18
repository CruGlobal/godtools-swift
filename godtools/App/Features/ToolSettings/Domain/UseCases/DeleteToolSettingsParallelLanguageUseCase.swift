//
//  DeleteToolSettingsParallelLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class DeleteToolSettingsParallelLanguageUseCase {
    
    private let deleteParallelLanguageRepository: DeleteToolSettingsParallelLanguageRepositoryInterface
    
    init(deleteParallelLanguageRepository: DeleteToolSettingsParallelLanguageRepositoryInterface) {
        
        self.deleteParallelLanguageRepository = deleteParallelLanguageRepository
    }
    
    func deletePublisher() -> AnyPublisher<Void, Never> {
        
        return deleteParallelLanguageRepository.deletePublisher()
    }
}
