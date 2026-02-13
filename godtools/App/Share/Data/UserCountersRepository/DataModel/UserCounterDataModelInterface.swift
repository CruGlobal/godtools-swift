//
//  UserCounterDataModelInterface.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol UserCounterDataModelInterface {
    
    var id: String { get }
    var latestCountFromAPI: Int { get }
    var incrementValue: Int { get }
}
