//
//  ResourcesApiType.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ResourcesApiType {
    
    func getResourcesJson(complete: @escaping ((_ result: Result<ResourcesJson, ResourcesApiError>) -> Void)) -> OperationQueue
}
