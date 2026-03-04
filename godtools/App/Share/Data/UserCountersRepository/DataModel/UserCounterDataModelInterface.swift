//
//  UserCounterDataModelInterface.swift
//  godtools
//
//  Created by Levi Eggert on 3/4/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol UserCounterDataModelInterface {
    
    var id: String { get }
    var count: Int { get }
    var localCount: Int { get }
}
