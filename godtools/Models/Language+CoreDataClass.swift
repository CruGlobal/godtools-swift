//
//  Language+CoreDataClass.swift
//  godtools
//
//  Created by Ryan Carlson on 4/18/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreData

@objc(Language)
public class Language: NSManagedObject {

    func localizedName() -> String {
        let localizedName = NSLocale.current.localizedString(forLanguageCode: self.code!)
        
        if localizedName == nil {
            return self.code!
        }
        
        return localizedName!
    }
    
    func isPrimary() -> Bool {
        return remoteId == GTSettings.shared.primaryLanguageId
    }
    
    func isParallel() -> Bool {
        return remoteId == GTSettings.shared.parallelLanguageId
    }
}
