//
//  GetGlobalActivityIsEnabledInterface.swift
//  godtools
//
//  Created by Levi Eggert on 1/15/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetGlobalActivityIsEnabledInterface {
    
    func getIsEnabledPublisher() -> AnyPublisher<Bool, Never>
}
