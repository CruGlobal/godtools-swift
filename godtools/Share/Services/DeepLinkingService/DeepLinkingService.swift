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
    
    private var deepLinkUrl: URL?
        
    let processing: ObservableValue<Bool> = ObservableValue(value: false)
    let completed: ObservableValue<DeepLinkingType> = ObservableValue(value: .none)
    
    required init(dataDownloader: InitialDataDownloader) {
        
        self.dataDownloader = dataDownloader
        
        super.init()
        
        setupBinding()
    }
    
    deinit {
        dataDownloader.completed.removeObserver(self)
    }
    
    private func setupBinding() {
        dataDownloader.completed.addObserver(self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.processDeepLinkIfNeeded()
            }
        }
    }
    
    private func processDeepLinkIfNeeded() {
        if let url = deepLinkUrl {
            processDeepLink(url: url)
        }
    }
    
    func processDeepLink(url: URL) {
        
        guard let host = url.host, !host.isEmpty else {
            return
        }
        
        guard dataDownloader.resourcesExistInDatabase else {
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
        
        let queryComponents: [String] = url.query?.components(separatedBy: "&") ?? []
        
        for component in queryComponents {
            
            let keyValue: [String] = component.components(separatedBy: "=")
            let isValidKeyValuePair: Bool = keyValue.count == 2
            
            guard isValidKeyValuePair else {
                continue
            }
            
            let key: String = keyValue[0]
            let value: String = keyValue[1]
            
            if parallelLanguage == nil && key == "parallelLanguage" && !value.isEmpty, let queryParallelLanguage = dataDownloader.languagesCache.getLanguage(code: value) {
                parallelLanguage = queryParallelLanguage
            }
        }
        
        print("\n PROCESS DEEP LINK")
        print("  host: \(url.host)")
        print("  path components: \(url.pathComponents)")
        print("  query: \(url.query)")
        print("  primaryLanguage: \(primaryLanguage)")
        print("  resource: \(resource)")
        print("  page: \(page)")
        
        processing.accept(value: false)
        deepLinkUrl = nil
        
        if let resource = resource, let primaryLanguage = primaryLanguage {
            completed.accept(value: .tool(resource: resource, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, page: page))
        }
        else {
            completed.accept(value: .none)
        }
    }
}
