//
//  CallbackValueHandler.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class CallbackValueHandler<T> {
    
    let handle: ((_ value: T) -> Void)
    
    required init(handle: @escaping ((_ value: T) -> Void)) {
        self.handle = handle
    }
}
