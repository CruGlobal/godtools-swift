//
//  GlobalActivityServices.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct GlobalActivityServices: GlobalActivityServicesType {
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseUrl: String
    
    init(config: ConfigType) {
        
        session = SessionBuilder().buildIgnoringCacheSession()
        baseUrl = config.mobileContentApiBaseUrl
    }
        
    var globalAnalyticsOperation: SessionDataOperation {
        
        let urlRequest: URLRequest = requestBuilder.buildRequest(
            session: session,
            urlString: baseUrl + "/analytics/global",
            method: .get,
            headers: nil,
            httpBody: nil
        )
        
        return SessionDataOperation(session: session, urlRequest: urlRequest)
    }

    func getGlobalAnalytics(complete: @escaping ((_ result: Result<GlobalAnalytics?, Error>) -> Void)) -> OperationQueue? {
        
        return getSessionDataObject(operation: globalAnalyticsOperation, complete: complete)
    }
}
