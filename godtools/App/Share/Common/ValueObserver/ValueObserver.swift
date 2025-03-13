//
//  ValueObserver.swift
//  godtools
//
//  Created by Levi Eggert on 3/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class ValueObserver<T>: ObservableObject {
    
    @Published var value: T
    
    init(value: T) {
        
        self.value = value
    }
}
