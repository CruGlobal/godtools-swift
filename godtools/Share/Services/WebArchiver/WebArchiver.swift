//
//  WebArchiver.swift
//  godtools
//
//  Created by Igor Ostriz, based on work by Ernesto Elsäßer and BiblioArchiver
//  Copyright © 2018 Cru. All rights reserved.
//


import Foundation
import Fuzi

public class WebArchiver {
    
    enum ArchivingResult {
        case success(plistData: Data)
        case failure(error: Error)
    }
    
    private struct State {
        var archive: WebArchive
        var resourceErrors: [Error]
        var pendingTaskCount: Int
    }

    static var workQueue: DispatchQueue? {
        didSet {
            workQueue = oldValue ?? DispatchQueue(label: "WebArchiverWorkQueue")
        }
    }
    
    static let wq = DispatchQueue(label: "WebArchiverWorkQueue")
    
    static func archive(url: URL, completion: @escaping (ArchivingResult) -> ()) {
        
        let includeJavascript: Bool = true
        
        guard let host = url.host, let scheme = url.scheme, scheme == "https" else {
            completion(.failure(error: WebArchivingError.unsupportedUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            WebArchiver.wq.async {
            
                do {
                    let mainResource = try self.resourceFromResponse(url: url.absoluteString, data, response, error)
                    let references = try self.extractHTMLReferences(from: mainResource, host: host, includeJavascript: includeJavascript)
                    var state = State(archive: WebArchive(resource: mainResource), resourceErrors: [], pendingTaskCount: references.count - 1)
                    
                    for reference in references {
                        
                        guard let resourceUrl = URL(string: reference) else {
                            throw WebArchivingError.invalidReferenceUrl(string: reference)
                        }
                        
                        let task = URLSession.shared.dataTask(with: resourceUrl) { (data, response, error) in
                            
                            WebArchiver.wq.async {
                                do {
                                    let resource = try self.resourceFromResponse(url: reference, data, response, error)
                                    state.archive.addSubresource(resource)
                                } catch {
                                    state.resourceErrors.append(error)
                                }
                                state.pendingTaskCount = state.pendingTaskCount - 1
                                
                                if state.pendingTaskCount == 0  {
                                    let result = self.finish(with: state)
                                    DispatchQueue.main.async {
                                        completion(result)
                                    }
                                }
                            }
                            
                        }
                        task.resume()
                    }
                    
                } catch {
                    completion(.failure(error: error))
                }
            }
        }
        task.resume()
    }
    
    private static func resourceFromResponse(url: String, _ data: Data?, _ response: URLResponse?, _ error: Error?) throws -> WebArchiveResource {
        
        if let error = error {
            throw WebArchivingError.requestFailed(resource: url, error: error)
        }
        guard let data = data, let mimeType = (response as? HTTPURLResponse)?.mimeType else {
            throw WebArchivingError.invalidResponse(resource: url)
        }
        return WebArchiveResource(url: url, data: data, mimeType: mimeType)
    }
    
    private static func extractHTMLReferences(from resource: WebArchiveResource, host: String, includeJavascript: Bool) throws -> [String] {
        
        guard let htmlString = String(data: resource.data, encoding: .utf8) else {
            throw WebArchivingError.unsupportedEncoding
        }
        
        let doc = try HTMLDocument(string: htmlString, encoding: .utf8)
        
        var references: [String] = []
        references += doc.xpath("//img[@src]").compactMap{ $0["src"] } // images
        references += doc.xpath("//link[@rel='stylesheet'][@href]").compactMap{ $0["href"] } // css
        if includeJavascript {
            references += doc.xpath("//script[@src]").compactMap{ $0["src"] } // javascript
        }
        
        return references.map { ref in
            if ref.hasPrefix("https") {
                return ref
            } else if ref.hasPrefix("//") {
                return "https:\(ref)"
            } else if ref.hasPrefix("/") {
                return "https://\(host)\(ref)"
            } else {
                return "https://\(host)/\(ref)"
            }
        }
    }
    
    private static func finish(with state: State) -> ArchivingResult {

        if let error = state.resourceErrors.first {
            return .failure(error: error)
        }
        
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        
        do {
            let data = try encoder.encode(state.archive)
            return .success(plistData: data)
        } catch {
            return .failure(error: error)
        }
    }
}
