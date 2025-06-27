//
//  ToolSettingsFlowCompletedState.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum ToolSettingsFlowCompletedState {
    
    case toolScreenShareFlowStarted(toolSettingsObserver: ToolSettingsObserver)
    case userClosedToolSettings
}
