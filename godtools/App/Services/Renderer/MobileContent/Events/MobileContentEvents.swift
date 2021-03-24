//
//  MobileContentEvents.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class MobileContentEvents {
        
    let urlButtonTappedSignal: SignalValue<UrlButtonEvent> = SignalValue()
    
    deinit {
        print("x deinit: \(type(of: self)) ***")
    }
    
    func urlButtonTapped(urlButtonEvent: UrlButtonEvent) {
        urlButtonTappedSignal.accept(value: urlButtonEvent)
    }
}
