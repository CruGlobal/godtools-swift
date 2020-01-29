//
//  DeviceLanguagePreferences.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class DeviceLanguagePreferences: NSObject, LanguagePreferencesType {
    
    override init() {
        
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLocationChangedNotification(notification:)),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
    }
    
    var isEnglish: Bool {
        let languageCode: String? = NSLocale.current.languageCode
        return languageCode == "en" || languageCode == "en_US"
    }
    
   @objc func handleLocationChangedNotification(notification: Notification) {
    
        print("\nLocation changed")
        print("  object: \(String(describing: notification.object))")
        print("  userInfo: \(String(describing: notification.userInfo))")
    }
}
