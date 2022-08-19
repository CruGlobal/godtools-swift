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
        
        print("Hello DownloadInitialResourcesScript")
        
        let apiBaseUrl: String = "https://mobile-content-api.cru.org"
        let session: URLSession = getIgnoreCacheSession()
        
        let semaphore = DispatchSemaphore( value: 0)
        
        DownloadInitialResourcesScript.runScriptCancellable = createTemporaryAssetsDirectory()
            .flatMap({ result -> AnyPublisher<(resourcesData: Data, languagesData: Data), Error> in
                
                return getResourcesPlusLatestTranslationsAndAttachmentsPlusLanguagesData(
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
                
                return parseResourcePlusLatestTranslationsAndAttachmentsModel(resourcesData: result.resourcesData)
            })
            .flatMap({ result -> AnyPublisher<[Bool], Error> in
                
                return saveResourceAttachmentsToBundle(resourcesPlusLatestTranslationsAndAttachments: result)
            })
            .flatMap({ result -> AnyPublisher<String, Error> in
                                
                return deleteTemporaryAssetsDirectory()
            })
            .sink(receiveCompletion: { result in
                print("Finished DownloadInitialResourcesScript with result: \(result)")
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
                    
                    return Fail(error: getError(description: "Failed to create resources and languages json files at temporary assets url."))
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

// MARK: - Fetching Resources and Languages Data

extension DownloadInitialResourcesScript {
    
    private static func parseResourcePlusLatestTranslationsAndAttachmentsModel(resourcesData: Data) -> AnyPublisher<ResourcesPlusLatestTranslationsAndAttachmentsModel, Error> {
                
        do {
            
            let resources: ResourcesPlusLatestTranslationsAndAttachmentsModel = try JSONDecoder().decode(ResourcesPlusLatestTranslationsAndAttachmentsModel.self, from: resourcesData)
            
            return Just(resources).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        catch let error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    private static func getResourcesPlusLatestTranslationsAndAttachmentsPlusLanguagesData(session: URLSession, apiBaseUrl: String) -> AnyPublisher<(resourcesData: Data, languagesData: Data), Error> {
        
        return Publishers
            .CombineLatest(getResourcesPlusLatestTranslationsAndAttachments(session: session, apiBaseUrl: apiBaseUrl), getLanguages(session: session, apiBaseUrl: apiBaseUrl))
            .mapError {
                return $0 as Error
            }
            .flatMap({ (resources: (data: Data, response: URLResponse), languages: (data: Data, response: URLResponse)) -> AnyPublisher<(resourcesData: Data, languagesData: Data), Error> in
                
                let resourcesHttpStatusCode: Int = (resources.response as? HTTPURLResponse)?.statusCode ?? -1
                let languagesHttpStatusCode: Int = (languages.response as? HTTPURLResponse)?.statusCode ?? -1
                
                guard (resourcesHttpStatusCode >= 200 && resourcesHttpStatusCode < 400) && (languagesHttpStatusCode >= 200 && languagesHttpStatusCode < 400) else {
                    
                    return Fail(error: getError(description: "Failed to fetch resources.  Invalid httpStatusCode."))
                        .eraseToAnyPublisher()
                }
                
                return Just((resourcesData: resources.data, languagesData: languages.data))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private static func getResourcesPlusLatestTranslationsAndAttachments(session: URLSession, apiBaseUrl: String) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        
        let urlString: String = apiBaseUrl + "/resources?filter[system]=GodTools&include=latest-translations,attachments"
        
        guard let url = URL(string: urlString) else {
            
            let description: String = "Failed to create url from urlString: \(urlString)"
            let error: URLError = URLError(URLError.Code(rawValue: -1), userInfo: [NSLocalizedDescriptionKey: description])
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        let configuration = session.configuration
        
        var urlRequest = URLRequest(
            url: url,
            cachePolicy: configuration.requestCachePolicy,
            timeoutInterval: configuration.timeoutIntervalForRequest
        )

        urlRequest.httpMethod = "GET"
        
        return session.dataTaskPublisher(for: urlRequest)
            .eraseToAnyPublisher()
    }
    
    private static func getLanguages(session: URLSession, apiBaseUrl: String) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        
        let urlString: String = apiBaseUrl + "/languages"
        
        guard let url = URL(string: urlString) else {
            
            let description: String = "Failed to create url from urlString: \(urlString)"
            let error: URLError = URLError(URLError.Code(rawValue: -1), userInfo: [NSLocalizedDescriptionKey: description])
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        let configuration = session.configuration
        
        var urlRequest = URLRequest(
            url: url,
            cachePolicy: configuration.requestCachePolicy,
            timeoutInterval: configuration.timeoutIntervalForRequest
        )

        urlRequest.httpMethod = "GET"
        
        return session.dataTaskPublisher(for: urlRequest)
            .eraseToAnyPublisher()
    }
}

// MARK: - Save Resources Attachments To Bundle

extension DownloadInitialResourcesScript {
    
    private static func saveResourceAttachmentsToBundle(resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<[Bool], Error> {
        
        let attachmentIds: [String] = resourcesPlusLatestTranslationsAndAttachments.resources.map({$0.attrBanner})
                
        let attachments: [AttachmentModel] = resourcesPlusLatestTranslationsAndAttachments.attachments.filter({attachmentIds.contains($0.id)})
        
        let requests = attachments.map {
            downloadAttachmentAndSaveToBundle(attachment: $0)
        }
        
        return Publishers.MergeMany(requests)
            .collect()
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
                    
                    return Fail(error: getError(description: "Failed to create attachment file at temporary assets url."))
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

            return Fail(error: getError(description: "Failed to download attachment file. Invalid URL if file attribute."))
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
                    
                    return Fail(error: getError(description: "Failed to fetch attachment.  Invalid httpStatusCode."))
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
            
            return Fail(error: getError(description: "Failed to get SRCROOT from ProcessInfo."))
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
    
    private static func getError(description: String) -> Error {
        return NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
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
