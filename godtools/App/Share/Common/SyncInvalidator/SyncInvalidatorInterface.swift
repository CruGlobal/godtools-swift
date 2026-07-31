//
//  SyncInvalidatorInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/22/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

public protocol SyncInvalidatorInterface: Sendable {
    
    var shouldSync: Bool { get async }
    
    func didSync() async
    func resetSync() async
}
