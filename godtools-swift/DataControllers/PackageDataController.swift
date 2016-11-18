//
//  PackageDataController.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/26/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import Zip
import PromiseKit
import CoreData

class PackageDataController: NSObject {
    
    func updateFromRemote() -> Promise<GodToolsLanguage> {
        var code = GodToolsSettings.init().primaryLanguage()
        
        if (code == nil) {
            code = "en"
        }
        
        let language = loadLanguage(languageCode: code!)
        
        return GodtoolsAPI.sharedInstance.getPackagesFor(language: language!).then { (url) -> Promise<GodToolsLanguage> in
            FullPackageResponseHandler.init().extractAndProcessFileAt(location: url, language: language!)
            
            return Promise.init(value: language!)
        }
    }
    
    func loadLanguage (languageCode :String) -> GodToolsLanguage? {
        let languageFetchRequest :NSFetchRequest<GodToolsLanguage> = GodToolsLanguage.fetchRequest()
        languageFetchRequest.predicate = NSPredicate(format: "code = %@", languageCode)
        
        do {
            let languages = try GodToolsPersistence.context().fetch(languageFetchRequest)
            
            if (languages.count > 0) {
                return languages[0]
            }
        } catch {
            
        }
        return nil
    }
    
}
