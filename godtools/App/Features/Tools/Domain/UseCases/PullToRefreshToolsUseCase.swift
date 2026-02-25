//
//  PullToRefreshToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/25/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

final class PullToRefreshToolsUseCase {
    
    private let resourcesRepository: ResourcesRepository
    
    init(resourcesRepository: ResourcesRepository) {
        
        self.resourcesRepository = resourcesRepository
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<Void, Error> {
        
        let requestPriority: RequestPriority = .high
        
        return Publishers.Merge(
            refreshResources(
                requestPriority: requestPriority
            ),
            refreshPersonalizedTools(
                requestPriority: requestPriority
            )
        )
        .eraseToAnyPublisher()
    }
    
    private func refreshResources(requestPriority: RequestPriority) -> AnyPublisher<Void, Error> {
        
        return resourcesRepository
            .syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsPublisher(
                requestPriority: requestPriority,
                forceFetchFromRemote: true
            )
            .map { _ in
                return ()
            }
            .eraseToAnyPublisher()
    }
    
    private func refreshPersonalizedTools(requestPriority: RequestPriority) -> AnyPublisher<Void, Error> {
        
        // TODO: Refresh personalized tools. ~Levi
        
        return Just(Void())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
