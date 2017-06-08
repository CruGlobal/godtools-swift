//
//  TractViewControllerDataManagement.swift
//  godtools
//
//  Created by Devserker on 5/30/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

extension TractViewController {
    
    // MARK: - Management of languages
    
    func parallelLanguageIsAvailable() -> Bool {
        guard let parallelLanguage = languagesManager.loadParallelLanguageFromDisk() else {
            return false
        }
        
        return resource!.isAvailableInLanguage(parallelLanguage)
    }
    
    func determinePrimaryLabel() -> String {
        let primaryLanguage = languagesManager.loadPrimaryLanguageFromDisk()
        
        if primaryLanguage == nil {
            return Locale.current.localizedString(forLanguageCode: Locale.current.languageCode!)!
        } else {
            return primaryLanguage!.localizedName
        }
    }
    
    func determineParallelLabel() -> String {
        let parallelLanguage = languagesManager.loadParallelLanguageFromDisk()
        
        return parallelLanguage!.localizedName
    }
    
    func getLanguageTextAlignment() -> NSTextAlignment {
        return .left
    }
    
    // MARK: - Management of resources
    
    func getResourceData() {
        loadResourcesForLanguage()
        loadResourcesForParallelLanguage()
        usePrimaryLanguageResources()
        loadPagesIds()
    }
    
    func loadResourcesForLanguage() {
        let language = languagesManager.loadPrimaryLanguageFromDisk()
        let content = self.tractsManager.loadResource(resource: self.resource!, language: language!)
        self.xmlPagesForPrimaryLang = content.pages
        self.colors = content.colors
    }
    
    func loadResourcesForParallelLanguage() {
        if parallelLanguageIsAvailable() {
            let parallelLanguage = languagesManager.loadParallelLanguageFromDisk()
            let content = self.tractsManager.loadResource(resource: self.resource!, language: parallelLanguage!)
            self.xmlPagesForParallelLang = content.pages
        }
    }
    
    func loadPagesIds() {
        var counter = 0
        for page in self.xmlPages {
            for listener in page.pageListeners()! {
                TractBindings.addPageBinding(listener, counter)
            }
            
            counter += 1
        }
    }
    
    func usePrimaryLanguageResources() {
        self.xmlPages = self.xmlPagesForPrimaryLang
    }
    
    func useParallelLanguageResources() {
        self.xmlPages = self.xmlPagesForParallelLang
    }
    
    func getPage(_ pageNumber: Int) -> TractPage {
        return self.xmlPages[pageNumber]
    }
    
    func totalPages() -> Int {
        return self.xmlPages.count;
    }
    
}
