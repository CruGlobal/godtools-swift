//
//  GetPersonalizedLessonFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetPersonalizedLessonFilterLanguagesUseCase: Sendable {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    
    init(
        resourcesRepository: ResourcesRepository,
        languagesRepository: LanguagesRepository
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
    }
    
    @MainActor func execute(
        appLanguage: AppLanguageDomainModel
    ) -> AnyPublisher<[ToolLanguageFilterDomainModel], Error> {
            
        return resourcesRepository
            .observeCollectionChangesPublisher()
            .receive(on: DispatchQueue.global())
            .flatMap { (resourcesChanged: Void) -> AnyPublisher<[ToolLanguageFilterDomainModel], Error> in
                
                return AnyPublisher() {
                    try await self.asyncExecute(appLanguage: appLanguage)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel) async throws -> [ToolLanguageFilterDomainModel] {
        
        return Array()
    }
}
