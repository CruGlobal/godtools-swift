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
    let contentErrorSignal: SignalValue<ContentEventError> = SignalValue()
    let followUpEventButtonTappedSignal: SignalValue<FollowUpButtonEvent> = SignalValue()
    
    func eventButtonTapped(eventButton: ButtonEvent) {
        eventButtonTappedSignal.accept(value: eventButton)
    }
    
    func urlButtonTapped(urlButtonEvent: UrlButtonEvent) {
        urlButtonTappedSignal.accept(value: urlButtonEvent)
    }
    
    func contentError(error: ContentEventError) {
        contentErrorSignal.accept(value: error)
    }
    
    func followUpEventButtonTapped(followUpEventButton: FollowUpButtonEvent) {
        followUpEventButtonTappedSignal.accept(value: followUpEventButton)
    }
}
