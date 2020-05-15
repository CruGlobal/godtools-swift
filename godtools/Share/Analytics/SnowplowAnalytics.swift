//
//  SnowplowAnalytics.swift
//  godtools
//
//  Created by Robert Eldredge on 5/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SnowplowTracker

class SnowplowAnalytics: SnowplowAnalyticsType  {

    private let tracker: SPTracker
    private let loggingEnabled: Bool

    required init(config: ConfigType, loggingEnabled: Bool) {
        
        self.loggingEnabled = loggingEnabled
        
        let urlEndpoint: String = "s.cru.org"
        let trackerNamespace: String = "godtools-ios"
        
        let emitter = SPEmitter.build({ (builder: SPEmitterBuilder?) in
            guard let builder = builder else {
                return
            }
            builder.setUrlEndpoint(urlEndpoint)
            builder.setHttpMethod(.post)
            builder.setProtocol(.https)
        })
        
        let subject = SPSubject(
            platformContext: true,
            andGeoContext: true
        )
        
        tracker = SPTracker.build({ (builder: SPTrackerBuilder?) in
            guard let builder = builder else {
                return
            }
            builder.setEmitter(emitter)
            builder.setAppId(config.snowplowAppId)
            builder.setTrackerNamespace(trackerNamespace)
            builder.setSubject(subject)
            builder.setSessionContext(true)
            builder.setApplicationContext(true)
            builder.setLifecycleEvents(true)
        })
    }

    func trackScreenView(screenName: String, contexts: [[String: Any]]) {
        
        let event = SPScreenView.build { (builder: SPScreenViewBuilder) in
            builder.setName(screenName)
            if !contexts.isEmpty {
                builder.setContexts(NSMutableArray(array: contexts))
            }
        }
        
        DispatchQueue.global().async { [weak self] in
            self?.tracker.trackScreenViewEvent(event)
        }
        
        log(method: "trackScreenView()", label: "screenName", labelValue: screenName, data: nil)
    }

    func trackAction(action: String, contexts: [[String: Any]]) {
        
        let event = SPStructured.build { (builder: SPStructuredBuilder) in
            builder.setAction(action)
            if !contexts.isEmpty {
                builder.setContexts(NSMutableArray(array: contexts))
            }
        }
        
        DispatchQueue.global().async { [weak self] in
            self?.tracker.trackStructuredEvent(event)
        }
        
        log(method: "trackAction()", label: "action", labelValue: action, data: nil)
    }
    
    private func log(method: String, label: String?, labelValue: String?, data: [AnyHashable: Any]?) {
        
        if loggingEnabled {
            print("\nSnowplowTracker \(method)")
            if let label = label, let labelValue = labelValue {
               print("  \(label): \(labelValue)")
            }
            if let data = data {
                print("  data: \(data)")
            }
        }
    }
}
