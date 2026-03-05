//
//  GetUserActivityUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsShared

final class GetUserActivityUseCase {
    
    private let getUserActivityBadgeUseCase: GetUserActivityBadgeUseCase
    private let getUserActivityStatsUseCase: GetUserActivityStatsUseCase
    private let userCounterRepository: UserCountersRepository
    private let completedTrainingTipRepository: CompletedTrainingTipRepository
    
    init(getUserActivityBadgeUseCase: GetUserActivityBadgeUseCase, getUserActivityStatsUseCase: GetUserActivityStatsUseCase, userCounterRepository: UserCountersRepository, completedTrainingTipRepository: CompletedTrainingTipRepository) {
        
        self.getUserActivityBadgeUseCase = getUserActivityBadgeUseCase
        self.getUserActivityStatsUseCase = getUserActivityStatsUseCase
        self.userCounterRepository = userCounterRepository
        self.completedTrainingTipRepository = completedTrainingTipRepository
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<UserActivityDomainModel, Error> {
        
        return userCounterRepository
            .getUserCountersChangedPublisher()
            .map { (counters: [UserCounterDataModel]) in
                                
                let userActivityDomainModel: UserActivityDomainModel = self.getUserActivityDomainModel(
                    userCounters: counters,
                    translatedInAppLanguage: appLanguage
                )
                
                return userActivityDomainModel
            }
            .eraseToAnyPublisher()
    }
    
    private func getAllUserCounterDomainModels(userCounters: [UserCounterDataModel]) -> [UserCounterDomainModel] {
        
        var userCounterDomainModels = userCounters.map {
            UserCounterDomainModel(dataModel: $0)
        }
        
        let numberTipsCompleted = completedTrainingTipRepository.getNumberOfCompletedTrainingTips()
        
        let trainingTipsCounter = UserCounterDomainModel(
            id: UserCounterNames.shared.TIPS_COMPLETED,
            count: numberTipsCompleted
        )
        
        userCounterDomainModels.append(trainingTipsCounter)
        
        return userCounterDomainModels
    }
    
    private func getUserActivityDomainModel(userCounters: [UserCounterDataModel], translatedInAppLanguage: AppLanguageDomainModel) -> UserActivityDomainModel {
        
        let domainModels: [UserCounterDomainModel] = getAllUserCounterDomainModels(userCounters: userCounters)
        
        let userCounterDictionary = buildUserCounterDictionary(from: domainModels)
        
        let userActivity = UserActivity(counters: userCounterDictionary)
        
        let badges = userActivity.badges.map { self.getUserActivityBadgeUseCase.getBadge(from: $0, translatedInAppLanguage: translatedInAppLanguage) }
        let stats = getUserActivityStatsUseCase.getUserActivityStats(from: userActivity, translatedInAppLanguage: translatedInAppLanguage)
        
        return UserActivityDomainModel(badges: badges, stats: stats)
    }
    
    private func buildUserCounterDictionary(from counters: [UserCounterDomainModel]) -> [String: KotlinInt] {
        
        var dict = [String: KotlinInt]()
        
        for counter in counters {
            
            dict[counter.id] = KotlinInt(int: Int32(counter.count))
        }
        
        return dict
    }
}
