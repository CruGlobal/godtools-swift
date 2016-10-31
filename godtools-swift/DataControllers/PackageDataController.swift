//
//  PackageDataController.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/26/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import Zip

class PackageDataController: NSObject {
    
    func updateFromRemote() {
        var code = GodToolsSettings.init().primaryLanguage()
        
        if (code == nil) {
            code = "en"
        }
        
        GodtoolsAPI.sharedInstance.getPackages(forLanguage: code!).then { fileURL -> Void in
            FullPackageResponseHandler.init().extractAndProcessFileAt(location: fileURL, languageCode: code!)
            
        }.catch { (error) in
            debugPrint(error)
        }
    }
}
