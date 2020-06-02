//
//  SnowplowAnalytics.swift
//  godtools
//
//  Created by Robert Eldredge on 5/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SnowplowTracker
import TheKeyOAuthSwift

class SnowplowAnalytics: SnowplowAnalyticsType  {
   
    private let serialQueue: DispatchQueue = DispatchQueue(label: "snowplow.serial.queue")
    private let tracker: SPTracker
    private let keyAuthClient: TheKeyOAuthClient
    private let loggingEnabled: Bool
    
    private var visitorMarketingCloudID: String = ""
    
    private let idSchema = "iglu:org.cru/ids/jsonschema/1-0-3"
    private let uriSchema = "iglu:org.cru/content-scoring/jsonschema/1-0-0"
    
    private let actionURI = "godtools://action/"
    private let screenURI = "godtools://screenview/"
    
    private var isConfigured: Bool = false
    private var isConfiguring: Bool = false

    required init(config: ConfigType, keyAuthClient: TheKeyOAuthClient, loggingEnabled: Bool) {
        
        self.keyAuthClient = keyAuthClient
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
    
    func configure (adobeAnalytics: AdobeAnalyticsType) {
        if isConfigured || isConfiguring {
            return
        }
        
        isConfiguring = true
        
        serialQueue.async { [weak self] in
            self?.visitorMarketingCloudID = adobeAnalytics.visitorMarketingCloudID
            
            self?.isConfigured = true
            self?.isConfiguring = false
            
            self?.log(method: "configure()", label: nil, labelValue: nil, data: nil)
        }
    }
    
    private func assertFailureIfNotConfigured() {
        if !isConfigured {
            assertionFailure("Snowplow has not been configured.  Call configure() on application didFinishLaunching.")
        }
    }

    func trackScreenView(screenName: String) {
        let event = SPScreenView.build { (builder: SPScreenViewBuilder) in
            builder.setName(screenName)
            builder.setContexts([ self.idContext(), self.screenURI(screenName: screenName) ])
        }
            
        serialQueue.async { [weak self] in
            self?.tracker.trackScreenViewEvent(event)
        }
        
        log(method: "trackScreenView()", label: "screenName", labelValue: screenName, data: nil)
    }

    func trackAction(action: String) {
        let event = SPStructured.build { (builder: SPStructuredBuilder) in
            builder.setAction(action)
            builder.setContexts([ self.idContext(), self.actionURI(action: action) ])
        }
        
        serialQueue.async { [weak self] in
            self?.tracker.trackStructuredEvent(event)
        }
        
        log(method: "trackAction()", label: "action", labelValue: action, data: nil)
    }

    private func idContext() -> SPSelfDescribingJson {
        let grMasterPersonID: String? = keyAuthClient.isAuthenticated() ? keyAuthClient.grMasterPersonId : nil
        let marketingCloudID: String? = self.visitorMarketingCloudID
        let ssoguid: String? = keyAuthClient.isAuthenticated() ? keyAuthClient.guid : nil
        
        return SPSelfDescribingJson(schema: self.idSchema, andData: [
            "gr_master_person_id": grMasterPersonID,
            "mcid": marketingCloudID,
            "sso_guid": ssoguid,
        ] as NSObject)
    }
    
    private func screenURI(screenName: String) -> SPSelfDescribingJson {
        return SPSelfDescribingJson(schema: self.uriSchema, andData: [
            "uri": self.screenURI + screenName
        ] as NSObject)
    }
    
    private func actionURI(action: String) -> SPSelfDescribingJson {
        return SPSelfDescribingJson(schema: self.uriSchema, andData: [
            "uri": self.actionURI + action
        ] as NSObject)
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
