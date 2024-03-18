//
//  CombineObservableValue.swift
//  godtools
//
//  Created by Levi Eggert on 3/18/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class CombineObservableValue<T>: ObservableObject {
    
    @Published var value: T
    
    init(value: T) {
        
        self.value = value
    }
}
