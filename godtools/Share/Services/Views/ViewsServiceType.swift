//
//  ViewsServiceType.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ViewsServiceType {
    
    func addNewResourceViews(resourceIds: [String]) -> OperationQueue?
    func addFailedResourceViewsIfNeeded() -> OperationQueue?
}
