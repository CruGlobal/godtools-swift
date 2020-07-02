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
        
        let realmSHA256Files: [RealmSHA256File] = Array(realm.objects(RealmSHA256File.self))
        
        var realmSHA256FilesToDelete: [RealmSHA256File] = Array()
        
        for file in realmSHA256Files {
           
            print("sha file: \(file.sha256WithPathExtension)")
            print("  attachments: \(file.attachments.count)")
            print("  translations: \(file.translations.count)")
            
            if file.attachments.count == 0 && file.translations.count == 0 {
                
                let error: Error? = removeFile(location: file.location)
                
                if let error = error {
                    errors.append(error)
                }
                else {
                    print("    -> did delete old attachment file: \(file.location.sha256WithPathExtension)")
                    realmSHA256FilesToDelete.append(file)
                }
            }
        }
        
        guard !realmSHA256FilesToDelete.isEmpty else {
            return errors
        }
        
        do {
            try realm.write {
                print("\n    -> deleting realmSHA256Files: \(realmSHA256FilesToDelete.count)")
                realm.delete(realmSHA256FilesToDelete)
            }
        }
        catch let error {
            errors.append(error)
        }
        
        return errors
    }
}
