//
//  MetaDataController.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/26/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import CoreData

class MetaDataController: NSObject {
    let languagesFetch: NSFetchRequest<GodToolsLanguage> = GodToolsLanguage.fetchRequest()
    let persistenceContext = GodToolsPersistence.context()
    
    func updateFromRemote () {
        do {
//            if (try persistenceContext.fetch(languagesFetch).count == 0) {
            
                GodtoolsAPI.sharedInstance.getMeta().then() { json in
                    MetaResponseHandler.init().parse(data: json)
                }
//            }
        } catch {
            
        }
    }
}
