//
//  GetUserToolSettingsRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 6/3/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetUserToolSettingsRepositoryInterface {
    
    func getUserToolSettingsPublisher(toolId:  String) -> AnyPublisher<UserToolSettingsDomainModel?, Never>
}
