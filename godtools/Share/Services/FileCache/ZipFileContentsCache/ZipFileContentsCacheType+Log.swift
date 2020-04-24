//
//  ZipFileContentsCacheType+Log.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

extension ZipFileContentsCacheType {
    
    func logContentsAtLocation(location: ZipFileContentsCacheLocationType) {
        
        var logError: Error?
        
        switch getContentsDirectory(location: location) {
        case .success(let contentsDirectory):
            
            do {
                let contents: [String] = try fileManager.contentsOfDirectory(atPath: contentsDirectory.path)
                print("\n \(errorDomain): Logging contents at contents directory url: \(contentsDirectory.absoluteString)")
                for item in contents {
                    print("  item: \(item)")
                }
            }
            catch let error {
                logError = error
            }
        case .failure(let error):
            logError = error
            
        }
        
        if let error = logError {
            print("\n \(errorDomain): Failed to log contents with error: \(error)")
        }
    }
}
