//
//  FirebaseRemoteConfig.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class FirebaseRemoteConfig: RemoteConfigApiInterface {
 
    func getRemoteConfigPublisher() -> AnyPublisher<RemoteConfigDataModel, Never> {
        
        // TODO: Implement. ~Levi
        
        let dataModel = RemoteConfigDataModel(globalActivityIsEnabled: false, id: "1", updatedAt: Date())
        
        return Just(dataModel)
            .eraseToAnyPublisher()
    }
}
