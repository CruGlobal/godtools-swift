//
//  CallbackValueHandler.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated) // TODO: Deprecrating, instead use Combine subjects. ~Levi
class CallbackValueHandler<T> {
    
    let handle: ((_ value: T) -> Void)
    
    required init(handle: @escaping ((_ value: T) -> Void)) {
        self.handle = handle
    }
}
