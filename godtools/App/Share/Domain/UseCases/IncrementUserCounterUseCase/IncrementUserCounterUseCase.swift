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
        case sessionLaunch
        case linkShared
        case imageShared
        case tipsCompleted // TODO: - this gets pulled from the viewedTrainingTip cache right before we send all the counters to the shared library, we don't ever update this independently as each tip is completed
        case articleOpen(uri: String)
        case lessonOpen(tool: String)
        case toolOpen(tool: String)
        case screenShare(tool: String)
    }
    
    private let userCountersRepository: UserCountersRepository
    
    init(userCountersRepository: UserCountersRepository) {
        self.userCountersRepository = userCountersRepository
    }
    
    func incrementUserCounter(for interaction: UserCounterInteraction) -> AnyPublisher<UserCounterDomainModel, Error>? {
        
        guard let userCounterId = getUserCounterId(for: interaction) else { return nil }
        
        return userCountersRepository.incrementCachedUserCounterBy1(id: userCounterId)
            .flatMap { userCounterDataModel in
                
                let userCounterDomainModel = UserCounterDomainModel(dataModel: userCounterDataModel)
                
                return Just(userCounterDomainModel)
            }
            .eraseToAnyPublisher()
    }
    
    private func getUserCounterId(for interaction: UserCounterInteraction) -> String? {
        
        let userCounterNames = UserCounterNames.shared
        let userCounterId: String
        
        switch interaction {
            
        case .sessionLaunch:
            userCounterId = userCounterNames.SESSION
            
        case .linkShared:
            userCounterId = userCounterNames.LINK_SHARED
            
        case .imageShared:
            userCounterId = userCounterNames.IMAGE_SHARED
            
        case .tipsCompleted:
            
            assertionFailure("The total tips completed count gets pulled from the viewedTrainingTip cache right before we send all the counters to the shared library, we don't ever increment this independently as each tip is completed")
            return nil
            
        case .articleOpen(let uriString):
            
            guard let uri = URL(string: uriString) else { return nil }
            userCounterId = userCounterNames.ARTICLE_OPEN(uri: uri)
            
        case .lessonOpen(let tool):
            userCounterId = userCounterNames.LESSON_OPEN(tool: tool)
            
        case .toolOpen(let tool):
            userCounterId = userCounterNames.TOOL_OPEN(tool: tool)
            
        case .screenShare(let tool):
            userCounterId = userCounterNames.SCREEN_SHARE(tool: tool)
        }
        
        return userCounterId
    }
    
}
