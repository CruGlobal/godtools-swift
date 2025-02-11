//
//  DisabledRemoteConfigDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 1/15/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class DisabledRemoteConfigDatabase: RemoteConfigRemoteDatabaseInterface {
    
    init() {
        
    }
    
    func syncFromRemoteDatabasePublisher() -> AnyPublisher<Void, Never> {
        
        return Just(Void())
            .eraseToAnyPublisher()
    }
    
    func getRemoteConfigPublisher() -> AnyPublisher<RemoteConfigDataModel?, Never> {
        
        return Just(nil)
            .eraseToAnyPublisher()
    }
    
    func getRemoteConfig() -> RemoteConfigDataModel? {
        return nil
    }
}
