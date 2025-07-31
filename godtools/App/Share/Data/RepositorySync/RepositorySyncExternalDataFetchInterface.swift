//
//  RepositorySyncExternalDataFetchInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

public protocol RepositorySyncExternalDataFetchInterface {
    
    associatedtype DataModel
    
    func getObjectPublisher(id: String, requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<DataModel>, Never>
    func getObjectsPublisher(requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<DataModel>, Never>
}
