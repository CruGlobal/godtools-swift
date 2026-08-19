//
//  MobileContentRendererFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 8/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit

// TODO: This class can be dropped and instead use ResourcesFileCache once supporting async image loading in renderer. ~Levi
final class MobileContentRendererFileCache: Sendable {

    let rootDirectory: URL
    
    init() {
        
        let fileManager = FileManager.default
        let rootDirectoryName: String = ResourcesFileCache.rootDirectory
        
        let rootDirectory: URL

        do {
            
            rootDirectory = try FileCache.getUserDocumentsDirectory(fileManager: fileManager)
                .appendingPathComponent(rootDirectoryName)
        }
        catch let error {
            
            assertionFailure("WARNING: MobileContentRendererFileCache Failed to initialize rootDirectory with name: \(rootDirectoryName). Error: \(error.localizedDescription). Will use temporary directory.")
            
            rootDirectory = fileManager.temporaryDirectory
        }
        
        self.rootDirectory = rootDirectory
    }
    
    func getFile(location: FileCacheLocation) throws -> URL {
        
        guard let fileUrl = location.fileUrl else {
            
            let error: Error = NSError.errorWithDescription(
                description: "Found nil fileUrl on FileCacheLocation with relativeUrlString: \(location.relativeUrlString)"
            )
            
            throw error
        }
                
        return rootDirectory
            .appendingPathComponent(fileUrl.path)
    }
    
    func getData(location: FileCacheLocation) throws -> Data? {
        
        let fileManager = FileManager.default
        
        let url = try getFile(location: location)
        
        return fileManager.contents(atPath: url.path)
    }

    func getUIImageNonThrowing(location: FileCacheLocation) -> UIImage? {
        
        let fileManager = FileManager.default
        
        do {
                                       
            let data = try getData(location: location)
            
            guard let data = data else {
                return nil
            }
            
            return UIImage(data: data)
        }
        catch _ {
            return nil
        }
    }
}
