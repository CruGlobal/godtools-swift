//
//  DownloadInitialResourcesScript.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

@main
enum DownloadInitialResourcesScript {
             
    private static var runScriptCancellable: AnyCancellable?
    
    static func main() {
          
        let apiBaseUrl: String = "https://mobile-content-api.cru.org"
        let session: URLSession = getIgnoreCacheSession()
        
        let semaphore = DispatchSemaphore( value: 0)
        
        DownloadInitialResourcesScript.runScriptCancellable = createTemporaryAssetsDirectory()
            .flatMap({ result -> AnyPublisher<(resourcesData: Data, languagesData: Data), Error> in
                
                return GetResourcesAndLanguagesData.getResourcesPlusLatestTranslationsAndAttachmentsPlusLanguagesData(
                    session: session,
                    apiBaseUrl: apiBaseUrl
                )
            })
            .flatMap({ result -> AnyPublisher<(resourcesData: Data, languagesData: Data), Error> in
                
                return saveResourcesAndLanguagesDataToBundleAsJsonFile(
                    resourcesData: result.resourcesData,
                    languagesData: result.languagesData
                )
            })
            .flatMap({ result -> AnyPublisher<ResourcesPlusLatestTranslationsAndAttachmentsModel, Error> in
                
                return GetResourcesAndLanguagesData.parseResourcePlusLatestTranslationsAndAttachmentsModel(resourcesData: result.resourcesData)
            })
            .flatMap({ result -> AnyPublisher<[Bool], Error> in
                
                return saveResourceAttachmentsToBundle(resourcesPlusLatestTranslationsAndAttachments: result)
            })
            .flatMap({ result -> AnyPublisher<String, Error> in
                                
                return deleteTemporaryAssetsDirectory()
            })
            .sink(receiveCompletion: { result in
                semaphore.signal()
            }, receiveValue: { result in
                
            })
        
        semaphore.wait()
    }
}

// MARK: - Save Resources and Languages Json Files to Bundle

extension DownloadInitialResourcesScript {
    
    private static func saveResourcesAndLanguagesDataToBundleAsJsonFile(resourcesData: Data, languagesData: Data) -> AnyPublisher<(resourcesData: Data, languagesData: Data), Error> {
        
        return getTemporaryAssetsFileUrl()
            .flatMap({ temporaryAssetsUrl -> AnyPublisher<(resourcesData: Data, languagesData: Data), Error> in
                                
                let resourcesJsonFileUrl: URL = temporaryAssetsUrl.appendingPathComponent(getResourcesJsonFilePath())
                let languagesJsonFileUrl: URL = temporaryAssetsUrl.appendingPathComponent(getLanguagesJsonFilePath())
                                
                let didCreateResourcesJsonFile: Bool = FileManager.default.createFile(atPath: resourcesJsonFileUrl.path, contents: resourcesData, attributes: nil)
                let didCreateLanguagesJsonFile: Bool = FileManager.default.createFile(atPath: languagesJsonFileUrl.path, contents: languagesData, attributes: nil)

                guard didCreateResourcesJsonFile && didCreateLanguagesJsonFile else {
                    
                    return Fail(error: NSError.errorWithDescription(description: "Failed to create resources and languages json files at temporary assets url."))
                        .eraseToAnyPublisher()
                }
                
                do {
                    
                    _ = try safeShell("cp -r \(getTemporaryAssetsShellFilePath())/\(getResourcesJsonFilePath()) ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}")
                    _ = try safeShell("cp -r \(getTemporaryAssetsShellFilePath())/\(getLanguagesJsonFilePath()) ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}")
                    
                    return Just((resourcesData: resourcesData, languagesData: languagesData))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                catch let error {
                                        
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Save Resources Attachments To Bundle

extension DownloadInitialResourcesScript {
        
    private static func saveResourceAttachmentsToBundle(resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<[Bool], Error> {
                      
        return GetResourcesAttachments.getResourceAttachments(resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments)
            .flatMap({ attachments -> AnyPublisher<[Bool], Error> in
                
                let requests = attachments.map {
                    downloadAttachmentAndSaveToBundle(attachment: $0)
                }
                
                return Publishers.MergeMany(requests)
                    .collect()
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private static func downloadAttachmentAndSaveToBundle(attachment: AttachmentModel) -> AnyPublisher<Bool, Error> {
        
        return getTemporaryAssetsFileUrl()
            .flatMap({ temporaryAssetsUrl -> AnyPublisher<(URL, Data), Error> in
                
                let getAttachmentData = getAttachmentFile(attachment: attachment)
                    .eraseToAnyPublisher()
                
                let justUrl = Just(temporaryAssetsUrl)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                
                return justUrl.zip(getAttachmentData)
                    .eraseToAnyPublisher()
            })
            .flatMap({ (temporaryAssetsUrl: URL, data: Data) -> AnyPublisher<Bool, Error> in
                
                let attachmentFileName: String = attachment.sha256
                let fileUrl: URL = temporaryAssetsUrl.appendingPathComponent(attachmentFileName)
                
                let didCreateAttachmentFile: Bool = FileManager.default.createFile(
                    atPath: fileUrl.path,
                    contents: data,
                    attributes: nil
                )
                
                guard didCreateAttachmentFile else {
                    
                    return Fail(error: NSError.errorWithDescription(description: "Failed to create attachment file at temporary assets url."))
                        .eraseToAnyPublisher()
                }
                
                do {
                    _ = try safeShell("cp -r \(getTemporaryAssetsShellFilePath())/\(attachmentFileName) ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}")
                    
                    return Just(true)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                catch let error {
                                        
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }
    
    private static func getAttachmentFile(attachment: AttachmentModel) -> AnyPublisher<Data, Error> {
        
        guard let url = URL(string: attachment.file) else {

            return Fail(error: NSError.errorWithDescription(description: "Failed to download attachment file. Invalid URL if file attribute."))
                .eraseToAnyPublisher()
        }
        
        let session: URLSession = getIgnoreCacheSession()
        
        return session.dataTaskPublisher(for: url)
            .mapError {
                return $0 as Error
            }
            .flatMap({ (result: (data: Data, response: URLResponse)) -> AnyPublisher<Data, Error> in
                
                let httpStatusCode: Int = (result.response as? HTTPURLResponse)?.statusCode ?? -1
                
                guard httpStatusCode >= 200 && httpStatusCode < 400 else {
                    
                    return Fail(error: NSError.errorWithDescription(description: "Failed to fetch attachment.  Invalid httpStatusCode."))
                        .eraseToAnyPublisher()
                }
                
                return Just(result.data)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - TemporaryAssets Directory

extension DownloadInitialResourcesScript {
        
    private static func getTemporaryAssetsPath() -> String {
        return "Scripts/TemporaryAssets"
    }
    
    private static func getTemporaryAssetsShellFilePath() -> String {
        return "${SRCROOT}/\(getTemporaryAssetsPath())"
    }
    
    private static func getTemporaryAssetsFileUrl() -> AnyPublisher<URL, Error> {
        
        guard let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"] else {
            
            return Fail(error: NSError.errorWithDescription(description: "Failed to get SRCROOT from ProcessInfo."))
                .eraseToAnyPublisher()
        }
        
        let temporaryAssetsUrl: URL = URL(fileURLWithPath: srcRoot).appendingPathComponent(getTemporaryAssetsPath())
        
        return Just(temporaryAssetsUrl).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private static func getResourcesJsonFilePath() -> String {
        return "resources.json"
    }
    
    private static func getLanguagesJsonFilePath() -> String {
        return "languages.json"
    }
    
    private static func createTemporaryAssetsDirectory() -> AnyPublisher<String, Error> {
        
        do {
            
            let result: String = try safeShell("mkdir \(getTemporaryAssetsShellFilePath())")
            
            return Just(result).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        catch let error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    private static func deleteTemporaryAssetsDirectory() -> AnyPublisher<String, Error> {
        
        do {
            
            let result: String = try safeShell("rm -r \(getTemporaryAssetsShellFilePath())")
            
            return Just(result).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        catch let error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}

// MARK: -

extension DownloadInitialResourcesScript {
    
    private static func getIgnoreCacheSession() -> URLSession {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 60
     
        return URLSession(configuration: configuration)
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
}
