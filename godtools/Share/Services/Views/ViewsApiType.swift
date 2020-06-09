//
//  ViewsApiType.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ViewsApiType {
    
    func newAddViewsOperation(resourceId: Int, quantity: Int) -> RequestOperation
    func addViews(resourceId: Int, quantity: Int, complete: @escaping ((_ result: Result<Data?, ResponseError<NoClientApiErrorType>>) -> Void)) -> OperationQueue
}
