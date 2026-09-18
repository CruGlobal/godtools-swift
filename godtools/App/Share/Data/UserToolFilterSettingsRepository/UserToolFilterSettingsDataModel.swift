//
//  UserToolFilterSettingsDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct UserToolFilterSettingsDataModel: Sendable, Equatable {
    
    let id: String
    let createdAt: Date
    let settingType: String
    let userId: String
    let value: String
}

extension UserToolFilterSettingsDataModel {
    
    static func createId(userId: String, settingType: UserToolFilterSettingType) -> String {
        return userId + "." + settingType.rawValue
    }
    
    init(userId: String, settingType: UserToolFilterSettingType, value: String, createdAt: Date) {
        
        self.init(
            id: Self.createId(userId: userId, settingType: settingType),
            createdAt: createdAt,
            settingType: settingType.rawValue,
            userId: userId,
            value: value
        )
    }
}
