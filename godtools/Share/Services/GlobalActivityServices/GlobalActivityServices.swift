//
//  GlobalActivityServices.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct GlobalActivityServices: GlobalActivityServicesType {
    
    func getGlobalAnalytics(complete: ((_ result: Result<[GlobalAnalytics], Error>) -> Void)) -> OperationQueue? {
        
        complete(.success([]))
        
        return nil
    }
}
