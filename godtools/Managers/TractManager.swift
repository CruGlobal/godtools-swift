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

}

extension TractManager {
    
    func loadResource(resource: DownloadedResource, language: Language) -> (pages: [XMLIndexer], colors: TractColors) {
        var pages = [XMLIndexer]()
        let tractColors = TractColors()
        
        guard let translation = resource.getTranslationForLanguage(language) else {
            return (pages, tractColors)
        }
        
        
        guard let manifestPath = translation.manifestFilename else {
            return (pages, tractColors)
        }
        
        
        let xmlData = loadXMLFile(manifestPath)
        guard let manifest = xmlData?["manifest"] else {
            return (pages, tractColors)
        }
        
        
        let primaryColorString: String = (manifest.element?.attribute(by: "primary-color")?.text) ?? GTAppDefaultColors.primaryColor
        let primaryTextColorString: String = (manifest.element?.attribute(by: "primary-text-color")?.text) ?? GTAppDefaultColors.primaryTextColorString
        let textColorString: String = (manifest.element?.attribute(by: "text-color")?.text) ?? GTAppDefaultColors.textColorString
        
        for child in manifest["pages"].children {
            if child.element?.name == "page" {
                let page = loadPage(child)
                pages.append(page)
            }
        }
        
        tractColors.primaryColor = primaryColorString.getRGBAColor()
        tractColors.primaryTextColor = primaryTextColorString.getRGBAColor()
        tractColors.textColor = textColorString.getRGBAColor()
        
        return (pages, tractColors)
    }
    
    func loadPage(_ child: XMLIndexer) -> XMLIndexer{
        let resource = child.element?.attribute(by: "src")?.text
        let page = loadXMLFile(resource!)
        return page!
    }
    
    func loadXMLFile(_ resourcePath: String) -> XMLIndexer? {
        let file = documentsPath.appending("/Resources/").appending(resourcePath)
        
        var xml: XMLIndexer?
        do {
            let content = try String(contentsOfFile: file, encoding: String.Encoding.utf8)
            
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
