//
//  ResourcesSHA256FileCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ResourcesSHA256FileCache: SHA256FilesCache {
    
    required init(rootDirectory: String = "godtools_resources_files") {
        
        super.init(rootDirectory: rootDirectory)
    }
    
    func deleteUnusedSHA256ResourceFiles(realm: Realm) -> [Error] {
        
        var errors: [Error] = Array()
        
        let query: String = "attachments.@count = 0 AND translations.@count = 0"
        let realmSHA256FilesToDelete: [RealmSHA256File] = Array(realm.objects(RealmSHA256File.self).filter(query))
           
        for file in realmSHA256FilesToDelete {
    
            let error: Error? = removeFile(location: file.location)
            
            if let error = error {
                errors.append(error)
            }
        }
        
        guard !realmSHA256FilesToDelete.isEmpty else {
            return errors
        }
        
        do {
            try realm.write {
                realm.delete(realmSHA256FilesToDelete)
            }
        }
        catch let error {
            errors.append(error)
        }
        
        return errors
    }
}
