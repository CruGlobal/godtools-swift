//
//  GetUserActivityStatsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 3/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import SwiftUI

class GetUserActivityStatsUseCase {
    
    func getUserActivityStats(from userActivity: UserActivity) -> [UserActivityStatDomainModel] {
        
        let toolOpensStat = UserActivityStatDomainModel(
            iconImageName: "tool-opens",
            text: "Tool opens",
            textColor: Color(red: 5 / 255, green: 105 / 255, blue: 155 / 255),
            value: String(userActivity.toolOpens)
        )
        
        
        return [toolOpensStat]
    }
}
