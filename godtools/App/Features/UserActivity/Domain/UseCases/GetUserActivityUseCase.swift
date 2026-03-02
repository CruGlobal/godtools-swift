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
            .getUserCountersChangedPublisher(
                reloadFromRemote: true,
                requestPriority: .high
            )
            .flatMap { (countersChanged: Void) -> AnyPublisher<[UserCounterDomainModel], Error> in
                
                return AnyPublisher() {
                    return try await self.getAllUserCounters()
                }
            }
            .map { (allUserCounters: [UserCounterDomainModel]) in
                                
                let userActivityDomainModel = self.getUserActivityDomainModel(
                    from: allUserCounters,
                    translatedInAppLanguage: appLanguage
                )
                
                return userActivityDomainModel
            }
            .eraseToAnyPublisher()
    }
    
    private func getAllUserCounters() async throws -> [UserCounterDomainModel] {
        
        var userCounters = try await userCounterRepository.getUserCounters().map {
            UserCounterDomainModel(dataModel: $0)
        }
        
        userCounters.append(getCompletedTrainingTipCounter())
        
        return userCounters
    }
    
    private func getCompletedTrainingTipCounter() -> UserCounterDomainModel {
        
        let numberTipsCompleted = completedTrainingTipRepository.getNumberOfCompletedTrainingTips()
        
        return UserCounterDomainModel(
            id: UserCounterNames.shared.TIPS_COMPLETED,
            count: numberTipsCompleted
        )
    }
    
    private func getUserActivityDomainModel(from counters: [UserCounterDomainModel], translatedInAppLanguage: AppLanguageDomainModel) -> UserActivityDomainModel {
        
        let userCounterDictionary = buildUserCounterDictionary(from: counters)
        
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
