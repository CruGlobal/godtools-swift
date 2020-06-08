//
//  GlobalActivityServicesType.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol GlobalActivityServicesType {
        
    var cachedGlobalAnalytics: GlobalActivityAnalytics? { get }
    
    func getGlobalAnalytics(complete: @escaping ((_ result: Result<GlobalActivityAnalytics?, ResponseError<NoClientApiErrorType>>) -> Void)) -> OperationQueue
}
