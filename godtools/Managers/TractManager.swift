//
//  TractManager.swift
//  godtools
//
//  Created by Devserker on 5/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash
import Crashlytics

class TractManager: GTDataManager {
    
    let testMode = false

}

extension TractManager {
    
    func loadResource(resource: DownloadedResource, language: Language) -> (pages: [TractPage], colors: TractColors) {
        var pages = [TractPage]()
        let tractColors = TractColors()
        var xmlData: XMLIndexer?
        
        if testMode {
            let manifestPath = "kgp-manifest"
            xmlData = loadXMLFile(manifestPath)
        
        } else {
            guard let translation = resource.getTranslationForLanguage(language) else {
                return (pages, tractColors)
            }
            
            
            guard let manifestPath = translation.manifestFilename else {
                return (pages, tractColors)
            }
            
            xmlData = loadXMLFile(manifestPath)
        }
        
        guard let manifest = xmlData?["manifest"] else {
            return (pages, tractColors)
        }
        
        let xmlManager = XMLManager()
        let manifestContent = xmlManager.getContentElements(manifest)
        
        let navBarColorString: String = (manifest.element?.attribute(by: "navbar-color")?.text) ?? GTAppDefaultColors.navBarColor
        let navBarControlColorString: String = (manifest.element?.attribute(by: "navbar-control-color")?.text) ?? GTAppDefaultColors.navBarControlColor
        let primaryColorString: String = (manifest.element?.attribute(by: "primary-color")?.text) ?? GTAppDefaultColors.primaryColor
        let primaryTextColorString: String = (manifest.element?.attribute(by: "primary-text-color")?.text) ?? GTAppDefaultColors.primaryTextColorString
        let textColorString: String = (manifest.element?.attribute(by: "text-color")?.text) ?? GTAppDefaultColors.textColorString
        
        let totalPages = manifest["pages"].children.count
        var currentPage = 1
        for child in manifest["pages"].children {
            if child.element?.name == "page" {
                let page = loadPage(child)
                page.pagination = TractPagination(totalPages: totalPages, pageNumber: currentPage)
                pages.append(page)
                currentPage += 1
            }
        }
        
        tractColors.navBarColor = navBarColorString.getRGBAColor()
        tractColors.navBarControlColor = navBarControlColorString.getRGBAColor()
        tractColors.primaryColor = primaryColorString.getRGBAColor()
        tractColors.primaryTextColor = primaryTextColorString.getRGBAColor()
        tractColors.textColor = textColorString.getRGBAColor()
        
        return (pages, tractColors)
    }
    
    func loadPage(_ child: XMLIndexer) -> TractPage{
        let resource = child.element?.attribute(by: "src")?.text
        let pageXML = loadXMLFile(resource!)
        let page = TractPage(withPageXML: pageXML!)
        return page
    }
    
    func loadXMLFile(_ resourcePath: String) -> XMLIndexer? {
        let file = testMode ? Bundle.main.path(forResource: resourcePath, ofType: "xml") : documentsPath.appending("/Resources/").appending(resourcePath)
        
        var xml: XMLIndexer?
        do {
            let content = try String(contentsOfFile: file!, encoding: String.Encoding.utf8)
            
            let regex = try! NSRegularExpression(pattern: "\n", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, content.characters.count)
            let modString = regex.stringByReplacingMatches(in: content, options: [], range: range, withTemplate: "")
            
            xml = SWXMLHash.parse(modString.condenseWhitespace())
        }
        catch {
            Crashlytics().recordError(error,
                                      withAdditionalUserInfo: ["customMessage": "Error while reading the XML"])
        }
        
        return xml
    }
    
}
