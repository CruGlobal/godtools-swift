//
//  RemoteConfigDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct RemoteConfigDataModel: Sendable {
    
    let globalActivityIsEnabled: Bool?
    let toolContentFeaturePageCollectionPageEnabled: Bool?
    let optInNotificationEnabled: Bool?
    let optInNotificationPromptLimit: Int?
    let optInNotificationTimeInterval: Int?
}
