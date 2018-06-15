//
//  TractAnalyticEvent.swift
//  godtools
//
//  Created by Greg Weiss on 6/15/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import Foundation

class TractAnalyticEvent {
    
    // Constants
    
    static let kAction = "action"
    static let kSystem = "system"
    static let kTrigger = "trigger"
    static let kDelay = "delay"
    
    // Properties
    
    var action: String = ""
    var system: String = ""
    var trigger: String = ""
    var delay: String = ""
    var attributes: [String: String] = [:]
    
    // Initialization
    
    init(dictionary: [String: String]) {
        
        self.attributes = dictionary
        
        if let action = dictionary[TractAnalyticEvent.kAction] {
            self.action = action
            self.attributes.removeValue(forKey: TractAnalyticEvent.kAction)
        }
        if let system = dictionary[TractAnalyticEvent.kSystem] {
            self.system = system
            self.attributes.removeValue(forKey: TractAnalyticEvent.kSystem)
        }
        if let trigger = dictionary[TractAnalyticEvent.kTrigger] {
            self.trigger = trigger
            self.attributes.removeValue(forKey: TractAnalyticEvent.kTrigger)
        }
        if let delay = dictionary[TractAnalyticEvent.kDelay] {
            self.delay = delay
            self.attributes.removeValue(forKey: TractAnalyticEvent.kDelay)
        }
    }
    
    // Convenience Init
    
    init() {
        self.action = ""
        self.system = ""
        self.trigger = ""
        self.delay = ""
        self.attributes = [:]
    }
    
    // Getting back a usable value
    
    static func convertToDictionary(from event: TractAnalyticEvent) -> [String: String] {
        
        var eventDictionary = event.attributes
        
        eventDictionary[TractAnalyticEvent.kAction] = event.action
        eventDictionary[TractAnalyticEvent.kSystem] = event.system
        eventDictionary[TractAnalyticEvent.kTrigger] = event.trigger
        eventDictionary[TractAnalyticEvent.kDelay] = event.delay
        
//        for attribute in event.attributes {
//            eventDictionary = eventDictionary.merging(attribute, uniquingKeysWith: { (_, last) in last })
//        }
        
        return eventDictionary
    }
    
}
