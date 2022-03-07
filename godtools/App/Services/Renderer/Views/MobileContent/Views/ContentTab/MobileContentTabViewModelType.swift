//
//  MobileContentTabViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

protocol MobileContentTabViewModelType {
    
    var labelText: String? { get }
    var tabListeners: [EventId] { get }
    
    func tabTapped()
}
