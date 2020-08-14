//
//  DeepLinkingService.swift
//  godtools
//
//  Created by Levi Eggert on 6/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class DeepLinkingService: NSObject {
    
    private let dataDownloader: InitialDataDownloader
    private let loggingEnabled: Bool
    
    private var deepLinkUrl: URL?
        
    let processing: ObservableValue<Bool> = ObservableValue(value: false)
    let completed: ObservableValue<DeepLinkingType> = ObservableValue(value: .none)
    
    required init(dataDownloader: InitialDataDownloader, loggingEnabled: Bool) {
        
        self.dataDownloader = dataDownloader
        self.loggingEnabled = loggingEnabled
        
        super.init()
        
        setupBinding()
    }
    
    deinit {
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
    }
    
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                if cachedResourcesAvailable {
                    self?.processDeepLinkIfNeeded()
                }
            }
        }
    }
    
    private func processDeepLinkIfNeeded() {
        if let url = deepLinkUrl {
            processDeepLink(url: url)
        }
    }
    
    func processDeepLink(url: URL) {
        
        if loggingEnabled {
            print("\n DeepLinkingService: processDeepLink() with url: \(url.absoluteString)")
        }
        
        guard let host = url.host, !host.isEmpty else {
            return
        }
                
        guard dataDownloader.cachedResourcesAvailable.value else {
            deepLinkUrl = url
            processing.accept(value: true)
            return
        }
        
        let pathComponents: [String] = url.pathComponents
        
        var primaryLanguage: LanguageModel?
        var resource: ResourceModel?
        var page: Int?
        
        for path in pathComponents {
            
            guard path != "/" else {
                continue
            }
            
            if primaryLanguage == nil, let pathPrimaryLanguage = dataDownloader.languagesCache.getLanguage(code: path) {
                primaryLanguage = pathPrimaryLanguage
            }
            else if resource == nil, let pathResource = dataDownloader.resourcesCache.getResource(abbreviation: path) {
                resource = pathResource
            }
            
            else if page == nil, let pathPage = Int(path) {
                page = pathPage
            }
        }
        
        var parallelLanguage: LanguageModel?
        var liveShareStream: String?
        
        let queryComponents: [String] = url.query?.components(separatedBy: "&") ?? []
        
        for component in queryComponents {
            
            let keyValue: [String] = component.components(separatedBy: "=")
            let isValidKeyValuePair: Bool = keyValue.count == 2
            
            guard isValidKeyValuePair else {
                continue
            }
            
            let key: String = keyValue[0]
            let value: String = keyValue[1]
            
            if key == "primaryLanguage" && !value.isEmpty {
                let primaryLanguageCodes: [String] = value.components(separatedBy: ",")
                for code in primaryLanguageCodes {
                    if let cachedPrimaryLanguage = dataDownloader.languagesCache.getLanguage(code: code) {
                        primaryLanguage = cachedPrimaryLanguage
                        break
                    }
                }
            }
            else if key == "parallelLanguage" && !value.isEmpty {
                let parallelLanguageCodes: [String] = value.components(separatedBy: ",")
                for code in parallelLanguageCodes {
                    if let cachedParallelLanguage = dataDownloader.languagesCache.getLanguage(code: code) {
                        parallelLanguage = cachedParallelLanguage
                        break
                    }
                }
            }
            else if key == "liveShareStream" {
                liveShareStream = value
            }
        }
                
        processing.accept(value: false)
        deepLinkUrl = nil
        
        print("\n DeepLinkingService: processDeepLink() url: \(url.absoluteString)")
        print("  parallelLanguage: \(String(describing: parallelLanguage?.code))")
        print("  liveShareStream: \(String(describing: liveShareStream))")
        
        if let resource = resource, let primaryLanguage = primaryLanguage {
            completed.accept(value: .tool(resource: resource, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, liveShareStream: liveShareStream, page: page))
        }
        else {
            completed.accept(value: .none)
        }
    }
}
