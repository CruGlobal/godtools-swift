//
//  MobileContentEvents.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class MobileContentEvents {
        
    let eventButtonTappedSignal: SignalValue<ButtonEvent> = SignalValue()
    let urlButtonTappedSignal: SignalValue<UrlButtonEvent> = SignalValue()
    
    func eventButtonTapped(eventButton: ButtonEvent) {
        eventButtonTappedSignal.accept(value: eventButton)
    }
    
    func urlButtonTapped(urlButtonEvent: UrlButtonEvent) {
        urlButtonTappedSignal.accept(value: urlButtonEvent)
    }
}
