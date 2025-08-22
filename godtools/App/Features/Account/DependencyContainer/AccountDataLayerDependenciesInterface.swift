//
//  AccountDataLayerDependenciesInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/21/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol AccountDataLayerDependenciesInterface {
    
    func getUserDetailsRepository() -> UserDetailsRepository
}
