//
//  LaunchCountTracker.swift
//  godtools
//
//  Created by Levi Eggert on 8/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit

@MainActor
final class LaunchCountTracker {
    
    private let launchCountRepository: LaunchCountRepositoryInterface

    private var incrementLaunchCountNeeded: Bool = true

    init(launchCountRepository: LaunchCountRepositoryInterface) {

        self.launchCountRepository = launchCountRepository
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUIApplicationLifeCycleNotification(notification:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUIApplicationLifeCycleNotification(notification:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    func incrementLaunchCountIfNeeded() async {

        guard incrementLaunchCountNeeded else {
            return
        }

        incrementLaunchCountNeeded = false

        let launchCount: Int = launchCountRepository.getLaunchCount()

        guard launchCount < Int.max else {
            return
        }

        let newLaunchCount: Int = launchCount + 1
        
        do {
            
            try await launchCountRepository.storeLaunchCount(count: newLaunchCount)
        }
        catch let error {
            
            assertionFailure(error.localizedDescription)
        }
    }

    @objc private func handleUIApplicationLifeCycleNotification(notification: Notification) {

        if notification.name == UIApplication.didBecomeActiveNotification {

            let tracker: LaunchCountTracker = self
            
            Task.detached {
                
                await tracker.incrementLaunchCountIfNeeded()
            }
        }
        else if notification.name == UIApplication.didEnterBackgroundNotification {

            incrementLaunchCountNeeded = true
        }
    }
}
