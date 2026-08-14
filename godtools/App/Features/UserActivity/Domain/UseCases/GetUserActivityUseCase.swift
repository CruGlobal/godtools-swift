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

final class GetUserActivityUseCase: Sendable {
    
    private let getUserActivityBadge: GetUserActivityBadge
    private let getUserActivityStats: GetUserActivityStats
    private let userCounterRepository: UserCountersRepository
    private let completedTrainingTipRepository: CompletedTrainingTipRepository
    
    init(
        getUserActivityBadge: GetUserActivityBadge,
        getUserActivityStats: GetUserActivityStats,
        userCounterRepository: UserCountersRepository,
        completedTrainingTipRepository: CompletedTrainingTipRepository
    ) {
        
        self.getUserActivityBadge = getUserActivityBadge
        self.getUserActivityStats = getUserActivityStats
        self.userCounterRepository = userCounterRepository
        self.completedTrainingTipRepository = completedTrainingTipRepository
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<UserActivityDomainModel, Error> {
        
        return userCounterRepository
            .observeCollectionChangesPublisher()
            .receive(on: DispatchQueue.global())
            .flatMap { (countersChanged: Void) -> AnyPublisher<UserActivityDomainModel, Error> in
                
                return AnyPublisher() {
                    
                    return try await self.asyncExecute(appLanguage: appLanguage)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel) async throws -> UserActivityDomainModel {
        
        let counters: [UserCounterDataModel] = try await userCounterRepository.getCachedCounters()
        
        return await getUserActivityDomainModel(
            userCounters: counters,
            translatedInAppLanguage: appLanguage
        )
    }
    
    private func getUserActivityDomainModel(
        userCounters: [UserCounterDataModel],
        translatedInAppLanguage: AppLanguageDomainModel
    ) async -> UserActivityDomainModel {

        let domainModels: [UserCounterDomainModel] = getAllUserCounterDomainModels(userCounters: userCounters)

        let userCounterDictionary = buildUserCounterDictionary(from: domainModels)

        let userActivity = UserActivity(counters: userCounterDictionary)

        var badges: [UserActivityBadgeDomainModel] = Array()

        for badge in userActivity.badges {

            badges.append(
                await getUserActivityBadge.getBadge(from: badge, translatedInAppLanguage: translatedInAppLanguage)
            )
        }

        let stats = await getUserActivityStats.getStats(from: userActivity, translatedInAppLanguage: translatedInAppLanguage)

        return UserActivityDomainModel(badges: badges, stats: stats)
    }
    
    private func getAllUserCounterDomainModels(userCounters: [UserCounterDataModel]) -> [UserCounterDomainModel] {
        
        var userCounterDomainModels = userCounters.map {
            UserCounterDomainModel(id: $0.id, count: $0.count)
        }
        
        let numberTipsCompleted = completedTrainingTipRepository.getNumberOfCompletedTrainingTips()
        
        let trainingTipsCounter = UserCounterDomainModel(
            id: UserCounterNames.shared.TIPS_COMPLETED,
            count: numberTipsCompleted
        )
        
        userCounterDomainModels.append(trainingTipsCounter)
        
        return userCounterDomainModels
    }
    
    private func buildUserCounterDictionary(from counters: [UserCounterDomainModel]) -> [String: KotlinInt] {
        
        var dict = [String: KotlinInt]()
        
        for counter in counters {
            
            dict[counter.id] = KotlinInt(int: Int32(counter.count))
        }
        
        return dict
    }
}
