//
//  RemoteConfigRemoteDatabaseInterface.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

protocol RemoteConfigRemoteDatabaseInterface {
    
    func syncFromRemoteDatabasePublisher() -> AnyPublisher<Void, Never>
    func getRemoteConfigPublisher() -> AnyPublisher<RemoteConfigDataModel?, Never>
    func getRemoteConfig() -> RemoteConfigDataModel?
}
