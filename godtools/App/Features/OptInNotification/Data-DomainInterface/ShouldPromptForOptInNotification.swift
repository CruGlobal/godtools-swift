//
//  ShouldPromptForOptInNotification.swift
//  godtools
//
//  Created by Levi Eggert on 4/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class ShouldPromptForOptInNotification: ShouldPromptForOptInNotificationInterface {
    
    private let launchCountRepository: LaunchCountRepositoryInterface
    private let optInNotificationRepository: OptInNotificationRepository
    private let checkNotificationStatus: GetCheckNotificationStatusInterface
    
    init(launchCountRepository: LaunchCountRepositoryInterface, optInNotificationRepository: OptInNotificationRepository, checkNotificationStatus: GetCheckNotificationStatusInterface) {
        
        self.launchCountRepository = launchCountRepository
        self.optInNotificationRepository = optInNotificationRepository
        self.checkNotificationStatus = checkNotificationStatus
    }
    
    func shouldPromptPublisher() -> AnyPublisher<Bool, Never> {
        
        let lastPrompted = optInNotificationRepository.getLastPrompted() ?? Date.distantPast

        let promptCount = optInNotificationRepository.getPromptCount()

        let currentDate = Date()
        let calendar = Calendar.current
        let twoMonthsAgo: Date? = calendar.date(
            byAdding: .month,
            value: -2,
            to: currentDate
        )
        
        print(lastPrompted)
        print(twoMonthsAgo ?? "")
        
        return Publishers.CombineLatest(
            launchCountRepository.getLaunchCountPublisher(),
            checkNotificationStatus.permissionStatusPublisher()
        )
        .map { (launchCount: Int, status: PermissionStatusDomainModel) in
            
            return false
        }
        .eraseToAnyPublisher()
    }
}
