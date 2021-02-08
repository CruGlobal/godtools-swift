//
//  DeepLinkingService.swift
//  godtools
//
//  Created by Levi Eggert on 6/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class DeepLinkingService: NSObject, DeepLinkingServiceType {
    
    private let deepLinkingParsers: DeepLinkParsersContainer = DeepLinkParsersContainer()
    private let loggingEnabled: Bool
    private let dataDownloader: InitialDataDownloader // TODO: Remove dataDownloader and handle this from the Flow.
    private let languageSettingsService: LanguageSettingsService
    
    private var deepLinkUrl: URL?
    private var deepLinkData: [AnyHashable: Any]?
        
    let processing: ObservableValue<Bool> = ObservableValue(value: false)
    let completed: ObservableValue<ParsedDeepLinkType?> = ObservableValue(value: nil)
    
    required init(loggingEnabled: Bool, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService) {
        
        self.loggingEnabled = loggingEnabled

        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        
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
        } else if let data = deepLinkData {
            processAppsflyerDeepLink(data: data)
        }
    }
    
    //MARK: - Public
    
    func parseDeepLink(incomingDeepLink: IncomingDeepLinkType) -> Bool {
        
        if loggingEnabled {
            print("\n DeepLinkingService: parseDeepLink()")
            print("  incomingDeepLink: \(incomingDeepLink)")
        }
                
        for deepLinkParser in deepLinkingParsers.parsers {
            if let deepLink = deepLinkParser.parse(incomingDeepLink: incomingDeepLink) {
                completed.accept(value: deepLink)
                return true
            }
        }
        
        completed.accept(value: nil)
        return false
    }
    
    func processDeepLink(url: URL) -> Bool {
        
        if loggingEnabled {
            print("\n DeepLinkingService: processDeepLink() with url: \(url.absoluteString)")
        }
        
        /*
        guard let host = url.host, !host.isEmpty else {
            return
        }
        
        guard dataDownloader.cachedResourcesAvailable.value else {
            deepLinkUrl = url
            processing.accept(value: true)
            return
        }
        
        if host.contains("godtoolsapp") {
            //Article Deep Link
            processArticleDeepLink(url: url)
        } else if host.contains("knowgod") {
            //Tool Deep Link
            processToolDeepLink(url: url)
        } else {
            //open URL link
            UIApplication.shared.open(url)
        }*/
        
        return false
    }
    
    func processAppsflyerDeepLink(data: [AnyHashable : Any]) {
        if loggingEnabled {
            print("\n DeepLinkingService: processAppsflyerDeepLink()")
        }
        
        guard dataDownloader.cachedResourcesAvailable.value else {
            deepLinkData = data
            processing.accept(value: true)
            return
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
                
        processing.accept(value: false)
        deepLinkData = nil
        
        guard let primaryLanguage = languageSettingsService.primaryLanguage.value, let resource = dataDownloader.resourcesCache.getResource(abbreviation: resourceName) else { return }
                
        //completed.accept(value: .tool(resource: resource, primaryLanguage: primaryLanguage, parallelLanguage: nil, liveShareStream: nil, page: nil))
    }
    
    //MARK: - Private
    
    private func processToolDeepLink(url: URL) {
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
            //completed.accept(value: .tool(resource: resource, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, liveShareStream: liveShareStream, page: page))
        }
        else {
            //completed.accept(value: .none)
        }
    }
    
    private func processArticleDeepLink(url: URL) {
        //TODO: open AEM article
    }
}
