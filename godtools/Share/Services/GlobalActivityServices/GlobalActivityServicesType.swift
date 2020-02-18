//
//  GlobalActivityServicesType.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol GlobalActivityServicesType: SessionDataServices {
    
    func getGlobalAnalytics(complete: @escaping ((_ result: Result<GlobalAnalytics?, Error>) -> Void)) -> OperationQueue?
}
