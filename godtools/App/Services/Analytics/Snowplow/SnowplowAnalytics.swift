//
//  SnowplowAnalytics.swift
//  godtools
//
//  Created by Robert Eldredge on 5/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SnowplowTracker

class SnowplowAnalytics  {
   
    private let oktaUserAuthentication: OktaUserAuthentication
    private let serialQueue: DispatchQueue = DispatchQueue(label: "snowplow.serial.queue")
    private let tracker: SPTracker
    private let loggingEnabled: Bool
    private let idSchema = "iglu:org.cru/ids/jsonschema/1-0-3"
    private let uriSchema = "iglu:org.cru/content-scoring/jsonschema/1-0-0"
    private let actionURI = "godtools://action/"
    private let screenURI = "godtools://screenview/"
    
    private var isConfigured: Bool = false
    private var isConfiguring: Bool = false

    required init(config: AppConfig, oktaUserAuthentication: OktaUserAuthentication, loggingEnabled: Bool) {
        
        self.oktaUserAuthentication = oktaUserAuthentication
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
    
    func configure () {
        
        if isConfigured || isConfiguring {
            return
        }
        
        isConfiguring = true
        
        serialQueue.async { [weak self] in
                        
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
           
        serialQueue.asyncAfter(deadline: .now() + 1) { [weak self] in
            
            guard let snowplow = self else {
                return
            }
            
            snowplow.assertFailureIfNotConfigured()
            snowplow.log(method: "trackScreenView()", label: "screenName", labelValue: screenName, data: nil)
            
            let event = SPScreenView.build { (builder: SPScreenViewBuilder) in
                builder.setName(screenName)
                builder.setContexts([ snowplow.idContext(), snowplow.screenURI(screenName: screenName) ])
            }
            
            snowplow.tracker.trackScreenViewEvent(event)
        }
    }
    
    func trackAction(actionName: String) {
        
        serialQueue.asyncAfter(deadline: .now() + 1) { [weak self] in
            
            guard let snowplow = self else {
                return
            }
            
            snowplow.assertFailureIfNotConfigured()
            snowplow.log(method: "trackAction()", label: "action", labelValue: actionName, data: nil)
            
            let event = SPStructured.build { (builder: SPStructuredBuilder) in
                builder.setAction(actionName)
                builder.setContexts([ snowplow.idContext(), snowplow.actionURI(action: actionName) ])
            }
            
            snowplow.tracker.trackStructuredEvent(event)
        }
    }

    private func idContext() -> SPSelfDescribingJson {
                
        let authUser: OktaAuthUserModel? = oktaUserAuthentication.authenticatedUser.value
        
        let grMasterPersonID: String = authUser?.grMasterPersonId ?? ""
        let ssoguid: String = authUser?.ssoGuid ?? ""
        let isAuthenticated: Bool = oktaUserAuthentication.isAuthenticated
        
        log(
            method: "idContext()",
            label: nil,
            labelValue: nil,
            data: [
                "grMasterPersonID": grMasterPersonID,
                "ssoguid": ssoguid,
                "isAuthenticated": isAuthenticated
            ]
        )
        
        return SPSelfDescribingJson(schema: idSchema, andData: [
            "gr_master_person_id": grMasterPersonID,
            "sso_guid": ssoguid,
        ] as NSObject)
    }
    
    private func screenURI(screenName: String) -> SPSelfDescribingJson {
        return SPSelfDescribingJson(schema: self.uriSchema, andData: [
            "uri": screenURI + screenName
        ] as NSObject)
    }
    
    private func actionURI(action: String) -> SPSelfDescribingJson {
        return SPSelfDescribingJson(schema: uriSchema, andData: [
            "uri": actionURI + action
        ] as NSObject)
    }
    
    private func log(method: String, label: String?, labelValue: String?, data: [String: Any]?) {
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
