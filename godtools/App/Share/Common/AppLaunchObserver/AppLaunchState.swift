//
//  AppLaunchState.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

enum AppLaunchState {
    
    case inBackground
    case fromBackgroundState(secondsInBackground: TimeInterval)
    case fromTerminatedState
    case notDetermined
}
