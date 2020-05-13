//
//  SnowplowAnalytics.swift
//  godtools
//
//  Created by Robert Eldredge on 5/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SnowplowTracker

class SnowplowAnalytics: NSObject, SnowplowAnalyticsType  {

    private let config: ConfigType
    private var emitter: SPEmitter? = nil
    private var subject: SPSubject? = nil
    private var tracker: SPTracker? = nil

    private let url: String! = "s.cru.org"
    private var isConfigured: Bool = false
    private var isConfiguring: Bool = false

    required init(config: ConfigType, loggingEnabled: Bool) {

        self.config = config

        super.init()
    }

    func configure(adobeAnalytics: AdobeAnalyticsType) {

        if isConfigured || isConfiguring {
            return
        }

        isConfiguring = true

        self.emitter = SPEmitter.build({ (builder : SPEmitterBuilder!) -> Void in
            builder.setUrlEndpoint(self.url)
            builder.setHttpMethod(.post)
            builder.setProtocol(.https)
        })
        subject = SPSubject(platformContext: true, andGeoContext: true)
        tracker = SPTracker.build({ (builder: SPTrackerBuilder!) -> Void in
            builder.setEmitter(self.emitter)
            builder.setAppId(self.config.snowplowAppId)
            builder.setSubject(self.subject)
            builder.setSessionContext(true)
            builder.setApplicationContext(true)
            builder.setLifecycleEvents(true)
        })
    }

    func trackScreenView(screenName: String!, data: NSMutableArray?) {
        self.assertFailureIfNotConfigured()
        
        let event = SPScreenView.build({ (builder : SPScreenViewBuilder!) -> Void in
            builder.setName(screenName)
            builder.setContexts(data)
        })
        tracker?.trackScreenViewEvent(event)
    }

    func trackAction(action: String!, data: NSMutableArray?) {
        self.assertFailureIfNotConfigured()
        
        let event = SPStructured.build({ (builder : SPStructuredBuilder!) -> Void in
            builder.setAction(action)
            builder.setContexts(data)
        })
        tracker?.trackStructuredEvent(event)
    }

    private func assertFailureIfNotConfigured() {
           if !isConfigured {
               assertionFailure("Snowplow has not been configured.  Call configure() on application didFinishLaunching.")
           }
       }
}
