//
//  FirebaseConfiguration.swift
//  godtools
//
//  Created by Levi Eggert on 3/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Firebase

class FirebaseConfiguration {
    
    private let config: ConfigType
        
    required init(config: ConfigType) {
        
        self.config = config
    }
    
    func configure() {
                
        let googleServiceName: String = config.firebaseGoogleServiceFileName
        
        guard let filePath = Bundle.main.path(forResource: googleServiceName, ofType: "plist") else {
            assertionFailure("WARNING: Failed to initialize firebase filePath with googleServiceName: \(googleServiceName)")
            return
        }
        
        guard let options = FirebaseOptions(contentsOfFile: filePath) else {
            assertionFailure("WARNING: Failed to initialize firebase options with filePath: \(filePath)")
            return
        }
        
        FirebaseApp.configure(options: options)
    }
}
