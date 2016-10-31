//
//  MetaDataController.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/26/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import PromiseKit

class MetaDataController: NSObject {    
    
    func updateFromRemote () -> Promise<Void> {
        return GodtoolsAPI.sharedInstance.getMeta().then() { json in
            MetaResponseHandler.init().parse(data: json)
        }
    }
}
