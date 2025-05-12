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
        case lessonCompletion(mobileContentAction: String)
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
            .flatMap { (userCounterDataModels: [UserCounterDataModel]) in
                
                // NOTE: Wondering if we should sync everytime an increment call is made?
                // Seems that could get expensive and if multiple increments are fired it could cause
                // duplicate requests to fire when iterating over user counters to sync. For example, someone is offline using the app
                // then connect back to the network.
                // Maybe this can be moved to AppFlow loadInitialData method or trigger peridically when network is available. ~Levi
                // Created SubTask GT-2612 in GT-2563.
                
                self.userCountersRepository.syncUpdatedUserCountersWithRemote(sendRequestPriority: .low)
                
                let userCounterDomainModel: UserCounterDomainModel
                
                if let dataModel = userCounterDataModels.first {
                    
                    userCounterDomainModel = UserCounterDomainModel(dataModel: dataModel)
                }
                else {
                    
                    userCounterDomainModel = UserCounterDomainModel(id: userCounterId, count: 0)
                }
                                
                return Just(userCounterDomainModel)
            }
            .eraseToAnyPublisher()
    }
    
    private func getUserCounterId(for interaction: UserCounterInteraction) -> String? {
        
        let userCounterNames = UserCounterNames.shared
        let userCounterId: String
        
        switch interaction {
            
        case .articleOpen(let uriString):
            
            guard let uri = URL(string: uriString) else {
                return nil
            }
            
            userCounterId = userCounterNames.ARTICLE_OPEN(uri: uri)
        
        case .imageShared:
            userCounterId = userCounterNames.IMAGE_SHARED
        
        case .languageUsed(let locale):
            userCounterId = userCounterNames.LANGUAGE_USED(locale: locale)
        
        case .lessonCompletion(let mobileContentAction):
            userCounterId = mobileContentAction
            
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
