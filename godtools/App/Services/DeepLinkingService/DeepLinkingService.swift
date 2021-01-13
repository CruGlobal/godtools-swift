//
//  DeepLinkingService.swift
//  godtools
//
//  Created by Levi Eggert on 6/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class DeepLinkingService: NSObject, DeepLinkingServiceType {
    
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let loggingEnabled: Bool
    
    private var deepLinkUrl: URL?
        
    let processing: ObservableValue<Bool> = ObservableValue(value: false)
    let completed: ObservableValue<DeepLinkingType> = ObservableValue(value: .none)
    
    required init(dataDownloader: InitialDataDownloader, loggingEnabled: Bool, languageSettingsService: LanguageSettingsService) {
        
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
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
            
            if primaryLanguage == nil, let pathPrimaryLanguage = dataDownloader.getStoredLanguage(code: path) {
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
        
        let components: URLComponents? = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems: [URLQueryItem] = components?.queryItems ?? []
                
        for queryItem in queryItems {
            
            let key: String = queryItem.name
            let value: String? = queryItem.value
                        
            if key == "primaryLanguage", let value = value {
                let primaryLanguageCodes: [String] = value.components(separatedBy: ",")
                for code in primaryLanguageCodes {
                    if let cachedPrimaryLanguage = dataDownloader.getStoredLanguage(code: code) {
                        primaryLanguage = cachedPrimaryLanguage
                        break
                    }
                }
            }
            else if key == "parallelLanguage", let value = value {
                let parallelLanguageCodes: [String] = value.components(separatedBy: ",")
                for code in parallelLanguageCodes {
                    if let cachedParallelLanguage = dataDownloader.getStoredLanguage(code: code) {
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
                
        if let resource = resource, let primaryLanguage = primaryLanguage {
            completed.accept(value: .tool(resource: resource, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, liveShareStream: liveShareStream, page: page))
        }
        else {
            completed.accept(value: .none)
        }
    }
    
    func processAppsflyerDeepLink(data: [AnyHashable : Any]) {
        
        if loggingEnabled {
            print("\n DeepLinkingService: processAppsflyerDeepLink()")
        }
        
        if let is_first_launch = data["is_first_launch"] as? Bool,
            is_first_launch {
            //Use if we want to trigger different behavior for deep link with fresh install
        }
        
        let resourceName: String
        
        if let deepLinkValue = data["deep_link_value"] as? String {
            
            resourceName = deepLinkValue
        } else {
            
            guard let linkParam = data["link"] as? String, let url = URLComponents(string: linkParam), let deepLinkValue = url.queryItems?.first(where: { $0.name == "deep_link_value" })?.value else { return }
            
            resourceName = deepLinkValue
        }
        
        guard dataDownloader.cachedResourcesAvailable.value else { return }        
        
        guard let primaryLanguage = languageSettingsService.primaryLanguage.value, let resource = dataDownloader.resourcesCache.getResource(abbreviation: resourceName) else {
            completed.accept(value: .none)
            return
        }
                
        completed.accept(value: .tool(resource: resource, primaryLanguage: primaryLanguage, parallelLanguage: nil, liveShareStream: nil, page: nil))
    }
}
