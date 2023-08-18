//
//  CallbackHandler.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated) // TODO: Deprecrating, instead use Combine subjects. ~Levi
class CallbackHandler {
    
    let handle: (() -> Void)
    
    init(handle: @escaping (() -> Void)) {
        self.handle = handle
    }
}
