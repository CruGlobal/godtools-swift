//
//  SwiftDatabaseConfigInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
protocol SwiftDatabaseConfigInterface {
    
    var modelConfiguration: ModelConfiguration { get }
}
