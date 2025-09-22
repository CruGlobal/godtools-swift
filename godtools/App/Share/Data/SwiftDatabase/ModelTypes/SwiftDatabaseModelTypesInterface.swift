//
//  SwiftDatabaseModelTypesInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
protocol SwiftDatabaseModelTypesInterface {
    
    func getModelTypes() -> any PersistentModel.Type
}
