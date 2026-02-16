//
//  IncrementUserCounterUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsShared

final class IncrementUserCounterUseCase {
    
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
    
    func execute(interaction: UserCounterInteraction) -> AnyPublisher<UserCounterDomainModel, Error> {
        
        guard let userCounterId = getUserCounterId(for: interaction) else {
            return Fail(error: UserCounterError.invalidUserCounterId)
                .eraseToAnyPublisher()
        }
        
        do {
            
            let userCounterDataModels: [UserCounterDataModel] = try userCountersRepository.incrementCachedUserCounterBy1(
                id: userCounterId
            )
            
            let userCounterDomainModel: UserCounterDomainModel
            
            if let dataModel = userCounterDataModels.first {
                userCounterDomainModel = UserCounterDomainModel(dataModel: dataModel)
            }
            else {
                userCounterDomainModel = UserCounterDomainModel(id: userCounterId, count: 0)
            }
            
            return Just(userCounterDomainModel)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        catch let error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
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
