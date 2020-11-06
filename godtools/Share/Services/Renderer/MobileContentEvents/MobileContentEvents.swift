//
//  MobileContentEvents.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class MobileContentEvents {
        
    let urlButtonTappedSignal: SignalValue<String> = SignalValue()
    
    func urlButtonTapped(url: String) {
        urlButtonTappedSignal.accept(value: url)
    }
}
