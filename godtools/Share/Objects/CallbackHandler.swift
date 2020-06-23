//
//  CallbackHandler.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class CallbackHandler {
    
    let handle: (() -> Void)
    
    required init(handle: @escaping (() -> Void)) {
        self.handle = handle
    }
}
