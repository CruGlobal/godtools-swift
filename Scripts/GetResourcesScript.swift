//
//  GetResourcesScript.swift
//  godtools
//
//  Created by Levi Eggert on 8/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

@main
enum GetResourcesScript {
         
    static func main() {
        
        print("Hello Xcode")
      
        if let value = ProcessInfo.processInfo.environment["PRODUCT_NAME"] {
            print("Product Name is: \(value)")
        }
        
        if let value = ProcessInfo.processInfo.environment["CONFIGURATION"] {
            print("Configuration is: \(value)")
        }
                
        if let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"], let targetName = ProcessInfo.processInfo.environment["TARGET_NAME"] {
            
            print("srcRoot: \(srcRoot)")
            print("targetName: \(targetName)")
            
            //let assetsPath: String = "\(srcRoot)/\(targetName)/Assets.xcassets"
            let assetsPath: String = "\(srcRoot)/\("godtools")"
            let assetsDirectory: URL = URL(fileURLWithPath: assetsPath).appendingPathComponent("Assets")
            let scriptAssetsDirectory: URL = assetsDirectory.appendingPathComponent("ScriptAssets")
            
            print("assetsDirectory: \(assetsDirectory.absoluteString)")
            print("scriptAssetsDirectory: \(scriptAssetsDirectory.absoluteString)")
            
            switch GetResourcesScript.createDirectoryIfNotExists(directoryUrl: assetsDirectory) {
            case .success(let url):
                print("did create assets: \(url.absoluteString)")
            case .failure(let error):
                print("Failed to create assets: \(error)")
            }
            
            switch GetResourcesScript.createDirectoryIfNotExists(directoryUrl: scriptAssetsDirectory) {
            case .success(let url):
                print("did create script assets: \(url.absoluteString)")
            case .failure(let error):
                print("Failed to create script assets: \(error)")
            }
            
            print("start resources request...")
            
            let semaphore = DispatchSemaphore( value: 0)
            var resourcesTask: URLSessionDataTask?
            
            let session: URLSession = GetResourcesScript.getSession()
            let resourcesRequest: URLRequest = URLRequest(url: URL(string: "https://mobile-content-api.cru.org/resources?include=latest-translations,attachments")!)
            
            resourcesTask = session.dataTask(with: resourcesRequest) { (data: Data?, response: URLResponse?, error: Error?) in
                
                print("resources request finished")
                
                if let data = data {
                    
                    let jsonFileUrl: URL = scriptAssetsDirectory.appendingPathComponent("script_assets.json")
                    print("creating resources json at url: \(jsonFileUrl.absoluteString)")
                    print("  path: \(jsonFileUrl.path)")
                    let success: Bool = FileManager.default.createFile(atPath: jsonFileUrl.path, contents: data, attributes: nil)
                    print("  create resources.json successful: \(success)")

                    print("did save script_assets.json to file cache")

                    do {
                        
                        // save script_assets to bundle directory
                        try GetResourcesScript.safeShell("cp -r ${SRCROOT}/godtools/Assets/ScriptAssets/script_assets.json ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}")
                                                
                        // delete Assets/ScriptAssets directory
                        try GetResourcesScript.safeShell("rm -r ${SRCROOT}/godtools/Assets/ScriptAssets")
                        
                        // delete bundle script assets
                        //try GetResourcesScript.safeShell("rm -r ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/script_assets.json")
                        //try GetResourcesScript.safeShell("rsync -av ${SRCROOT}/godtools/Assets/ScriptAssets/script_assets.json ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/")
                        print("did run shell rsync")
                    }
                    catch let error {
                        print("failed to copy resources.json with error: \(error)")
                    }
                }
                
                semaphore.signal()
            }
            
            resourcesTask?.resume()
            
            semaphore.wait()
        }
    }
    
    private static func safeShell(_ command: String) throws -> String {
        
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.standardInput = nil

        try task.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        return output
    }
    
    private static func getSession() -> URLSession {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 60
     
        return URLSession(configuration: configuration)
    }
    
    private static func createDirectoryIfNotExists(directoryUrl: URL) -> Result<URL, Error> {
        
        let fileManager: FileManager = FileManager.default
        
        guard !fileManager.fileExists(atPath: directoryUrl.path) else {
            return .success(directoryUrl)
        }
        
        do {
            try fileManager.createDirectory(
                at: directoryUrl,
                withIntermediateDirectories: true,
                attributes: nil
            )
            return .success(directoryUrl)
        }
        catch let error {
            return .failure(error)
        }
    }
}
