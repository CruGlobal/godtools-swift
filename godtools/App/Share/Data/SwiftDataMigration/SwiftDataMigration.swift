//
//  SwiftDataMigration.swift
//  godtools
//
//  Created by Levi Eggert on 8/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

@available(iOS, obsoleted: 19.0, message: "Can be obsoleted once SwiftData is used and Realm is dropped and enough time is given for users to migrate off realm.")
final class SwiftDataMigration: Sendable {
    
    private let launchCountRepository: LaunchCountRepositoryInterface
    
    init(launchCountRepository: LaunchCountRepositoryInterface) {
        
        self.launchCountRepository = launchCountRepository
    }
    
    func migrate() async {
        
        await migrateUserDefaultsLaunchCountIfNeeded()
    }
    
    private func migrateUserDefaultsLaunchCountIfNeeded() async {
        
        let userDefaultsLaunchCountKey: String = "LaunchCountCache.launchCountCacheKey"
        
        let userDefaults = UserDefaults.standard

        guard let userDefaultsLaunchCount = userDefaults.object(forKey: userDefaultsLaunchCountKey) as? Int else {
            return
        }

        do {

            try await launchCountRepository.storeLaunchCount(count: userDefaultsLaunchCount)

            userDefaults.removeObject(forKey: userDefaultsLaunchCountKey)
        }
        catch let error {

            assertionFailure("\n LaunchCountCache failed to migrate UserDefaults launch count with error: \(error)")
        }
    }
}
