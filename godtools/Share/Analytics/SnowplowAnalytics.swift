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
    private let emitter: SPEmitter
    private let subject: SPSubject
    private let tracker: SPTracker

    private let url: String! = "s.cru.org"
    private var isConfigured: Bool = false
    private var isConfiguring: Bool = false

    required init(config: ConfigType, loggingEnabled: Bool) {

        self.config = config
        self.loggingEnabled = loggingEnabled

        super.init()
    }

    func configure(adobeAnalytics: AdobeAnalyticsType) {

        if isConfigured || isConfiguring {
            return
        }

        isConfiguring = true

        emitter = SPEmitter.build({ (builder : SPEmitterBuilder!) -> Void in
            builder.setUrlEndpoint(url)
            builder.setHttpMethod(method: .post)
            builder.setProtocol(protocol: .https)
        })
        subject = SPSubject(platformContext: true, andGeoContext: true)
        tracker = SPTracker.build({ (builder: SPTrackerBuilder) -> Void in
            builder.setEmitter(emitter)
            builder.setAppId(config.appleAppId)
            builder.setSubject(subject)
            builder.setSessionContext(true)
            builder.setApplicationContext(true)
            builder.setLifecycleEvents(true)
        })
    }

    func trackScreenView() {
        <#code#>
    }

    func trackAction() {
        <#code#>
    }

    private func assertFailureIfNotConfigured() {
           if !isConfigured {
               assertionFailure("Snowplow has not been configured.  Call configure() on application didFinishLaunching.")
           }
       }
}
