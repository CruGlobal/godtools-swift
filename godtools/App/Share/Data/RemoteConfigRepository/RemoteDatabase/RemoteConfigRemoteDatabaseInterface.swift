//
//  RemoteConfigRemoteDatabaseInterface.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol RemoteConfigRemoteDatabaseInterface {
    
    func syncFromRemoteDatabase() async throws
    func getRemoteConfig() -> RemoteConfigDataModel?
}
