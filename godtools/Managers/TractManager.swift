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

class TractManager: NSObject {

}

extension TractManager {
    
    func loadResource(resource: DownloadedResource, language: Language) -> (pages: [XMLIndexer], colors: TractColors) {
        var pages = [XMLIndexer]()
        let tractColors = TractColors()
        
        let translation = resource.getTranslationForLanguage(language)
        if translation != nil {
            let manifestPath = translation?.manifestFilename
            if manifestPath != nil {
                let xmlData = loadXMLFile(manifestPath!)
                let manifest = xmlData?["manifest"]
                
                if manifest != nil {
                    let primaryColorString: String = (manifest!.element?.attribute(by: "primary-color")?.text) ?? "rgba(59, 164, 219, 1)"
                    let primaryTextColorString: String = (manifest!.element?.attribute(by: "primary-text-color")?.text) ?? "rgba(59, 164, 219, 1)"
                    let textColorString: String = (manifest!.element?.attribute(by: "text-color")?.text) ?? "rgba(90, 90, 90, 1)"
                    
                    for child in manifest!["pages"].children {
                        if child.element?.name == "page" {
                            let page = loadPage(child)
                            pages.append(page)
                        }
                    }
                    
                    tractColors.primaryColor = primaryColorString.getRGBAColor()
                    tractColors.primaryTextColor = primaryTextColorString.getRGBAColor()
                    tractColors.textColor = textColorString.getRGBAColor()
                }
            }
        }
        
        return (pages, tractColors)
    }
    
    func loadPage(_ child: XMLIndexer) -> XMLIndexer{
        let resource = child.element?.attribute(by: "src")?.text
        let page = loadXMLFile(resource!)
        return page!
    }
    
    func loadXMLFile(_ resourcePath: String) -> XMLIndexer? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
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
            print("error getting xml string: \(error)")
        }
        
        return xml
    }
    
}
