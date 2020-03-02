//
//  GlobalActivityAnalyticsApiType.swift
//  godtools
//
//  Created by Levi Eggert on 2/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol GlobalActivityAnalyticsApiType {
    
    func getGlobalAnalytics(complete: @escaping ((_ response: RequestResponse, _ result: RequestResult<GlobalActivityAnalytics, RequestClientError>) -> Void)) -> OperationQueue
}
