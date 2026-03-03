//
//  GetGlobalActivityEnabledUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 1/15/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetGlobalActivityEnabledUseCase {
    
    private let remoteConfigRepository: RemoteConfigRepository
    
    init(remoteConfigRepository: RemoteConfigRepository) {
        
        self.remoteConfigRepository = remoteConfigRepository
    }
    
    func execute() -> AnyPublisher<Bool, Never> {
        
        return remoteConfigRepository
            .getRemoteConfigPublisher()
            .map { (dataModel: RemoteConfigDataModel?) in
                return dataModel?.globalActivityIsEnabled ?? false
            }
            .eraseToAnyPublisher()
    }
}
