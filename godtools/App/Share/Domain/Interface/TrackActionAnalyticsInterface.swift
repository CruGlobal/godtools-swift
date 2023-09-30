//
//  TrackActionAnalyticsInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

protocol TrackActionAnalyticsInterface {
    
    func trackAction(properties: TrackActionAnalyticsPropertiesDomainModel)
}
