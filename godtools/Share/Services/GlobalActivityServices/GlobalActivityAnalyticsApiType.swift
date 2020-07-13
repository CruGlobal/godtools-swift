//
//  GlobalActivityAnalyticsApiType.swift
//  godtools
//
//  Created by Levi Eggert on 2/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol GlobalActivityAnalyticsApiType {
    
    func getGlobalAnalytics(complete: @escaping ((_ result: Result<GlobalActivityAnalytics?, ResponseError<NoClientApiErrorType>>) -> Void)) -> OperationQueue
}
