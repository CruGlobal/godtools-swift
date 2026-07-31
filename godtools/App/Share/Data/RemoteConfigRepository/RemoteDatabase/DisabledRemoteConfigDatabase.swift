//
//  DisabledRemoteConfigDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 1/15/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

actor DisabledRemoteConfigDatabase: RemoteConfigRemoteDatabaseInterface {
    
    init() {
        
    }
    
    func syncFromRemoteDatabase() async throws {
        
    }
    
    func getRemoteConfig() -> RemoteConfigDataModel? {
        return nil
    }
}
