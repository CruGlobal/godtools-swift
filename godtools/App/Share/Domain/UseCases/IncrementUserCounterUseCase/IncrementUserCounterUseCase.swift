//
//  IncrementUserCounterUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsToolParser

class IncrementUserCounterUseCase {
    
    enum UserCounterInteraction {
        case articleOpen(uri: String)
        case imageShared
        case languageUsed(locale: Locale)
        case lessonOpen(tool: String)
        case linkShared
        case screenShare(tool: String)
        case sessionLaunch
        case toolOpen(tool: String)
    }
    
    enum UserCounterError: Error {
        case invalidUserCounterId
    }
    
    private let userCountersRepository: UserCountersRepository
    
    init(userCountersRepository: UserCountersRepository) {
        self.userCountersRepository = userCountersRepository
    }
    
    func incrementUserCounter(for interaction: UserCounterInteraction) -> AnyPublisher<UserCounterDomainModel, Error> {
        
        guard let userCounterId = getUserCounterId(for: interaction) else {
            
            return Fail(error: UserCounterError.invalidUserCounterId)
                .eraseToAnyPublisher()
        }
        
        return userCountersRepository.incrementCachedUserCounterBy1(id: userCounterId)
            .flatMap { userCounterDataModel in
                
                self.userCountersRepository.syncUpdatedUserCountersWithRemote()
                
                let userCounterDomainModel = UserCounterDomainModel(dataModel: userCounterDataModel)
                
                return Just(userCounterDomainModel)
            }
            .eraseToAnyPublisher()
    }
    
    private func getUserCounterId(for interaction: UserCounterInteraction) -> String? {
        
        let userCounterNames = UserCounterNames.shared
        let userCounterId: String
        
        switch interaction {
            
        case .articleOpen(let uriString):
            
            guard let uri = URL(string: uriString) else { return nil }
            userCounterId = userCounterNames.ARTICLE_OPEN(uri: uri)
        
        case .imageShared:
            userCounterId = userCounterNames.IMAGE_SHARED
        
        case .languageUsed(let locale):
            userCounterId = userCounterNames.LANGUAGE_USED(locale: locale)
        
        case .lessonOpen(let tool):
            userCounterId = userCounterNames.LESSON_OPEN(tool: tool)
        
        case .linkShared:
            userCounterId = userCounterNames.LINK_SHARED
        
        case .screenShare(let tool):
            userCounterId = userCounterNames.SCREEN_SHARE(tool: tool)
        
        case .sessionLaunch:
            userCounterId = userCounterNames.SESSION
            
        case .toolOpen(let tool):
            userCounterId = userCounterNames.TOOL_OPEN(tool: tool)
            
        }
        
        return userCounterId
    }
    
}
