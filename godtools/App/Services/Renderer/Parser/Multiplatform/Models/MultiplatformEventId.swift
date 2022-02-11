//
//  MultiplatformEventId.swift
//  godtools
//
//  Created by Levi Eggert on 9/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformEventId: Equatable {
    
    private let eventId: EventId
    
    required init(eventId: EventId) {
        
        self.eventId = eventId
    }
    
    var name: String {
        return eventId.description()
    }
    
    func resolve(rendererState: State) -> [MultiplatformEventId] {
        
        return eventId.resolve(state: rendererState).map({MultiplatformEventId(eventId: $0)})
    }
    
    static func ==(thisEventId: MultiplatformEventId, thatEventId: MultiplatformEventId) -> Bool {
        return thisEventId.eventId == thatEventId.eventId
    }
    
    static var followUp: MultiplatformEventId {
        return MultiplatformEventId(eventId: EventId.Companion().FOLLOWUP)
    }
}
