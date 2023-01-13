//
//  LoadingViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LoadingViewModel: LoadingViewModelType {
    
    let message: ObservableValue<String> = ObservableValue(value: "")
    let hidesCloseButton: Bool = true
    
    required init(message: String) {
            
        self.message.accept(value: message)
    }
    
    func closeTapped() {
        
    }
    
    func pageViewed() {
        
    }
}
