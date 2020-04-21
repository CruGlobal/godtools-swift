//
//  ArticleManifestXmlParser.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ArticleManifestXmlParser: NSObject {
      
    private let xmlHash: XMLIndexer
    private let errorDomain: String
    
    required init(xmlData: Data) {
        
        xmlHash = SWXMLHash.parse(xmlData)
        errorDomain = String(describing: ArticleManifestXmlParser.self)
        
        super.init()
    }
    
    var title: String? {
        return xmlHash["manifest"]["title"]["content:text"].element?.text
    }
    
    func getManifestAttributes() -> Result<ArticleManifestAttributes, Error> {
        
        if let manifestAttributes = xmlHash["manifest"].element?.allAttributes {
            do {
                let data = try JSONSerialization.data(withJSONObject: manifestAttributes, options: [])
                let manifestAttributes = try JSONDecoder().decode(ArticleManifestAttributes.self, from: data)
                return .success(manifestAttributes)
            }
            catch let error {
                return .failure(error)
            }
        }
        
        let error = NSError(
            domain: errorDomain,
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Failed to locate manifest attributes."]
        )
        
        return .failure(error)
    }
    
    var categories: [ArticleCategory] {
                
        var categories: [ArticleCategory] = Array()
        
        for category in xmlHash["manifest"]["categories"]["category"].all {

            let id: String = category.element?.attribute(by: "id")?.text ?? ""
            let bannerFilename: String = category.element?.attribute(by: "banner")?.text ?? ""
            let title: String = category["label"]["content:text"].element?.text ?? ""
            let bannerSrc: String
            
            switch getResource(filename: bannerFilename) {
            case .success(let resource):
                bannerSrc = resource.src
            case .failure( _):
                bannerSrc = ""
            }
            
            var aemTags: [String] = Array()
            
            for articleTag in category["article:aem-tag"].all {
                if let id = articleTag.element?.attribute(by: "id")?.text {
                    aemTags.append(id)
                }
            }
                        
            let category = ArticleCategory(
                aemTags: aemTags,
                bannerFilename: bannerFilename,
                bannerSrc: bannerSrc,
                id: id,
                title: title
            )
            
            categories.append(category)
        }
        
        return categories
    }
    
    func getResource(filename: String) -> Result<ArticleResource, Error> {
        
        do {
            
            let resourceXml = try xmlHash["manifest"]["resources"]["resource"].withAttribute("filename", filename).element
            
            let resource = ArticleResource(
                filename: resourceXml?.attribute(by: "filename")?.text ?? "",
                src: resourceXml?.attribute(by: "src")?.text ?? ""
            )
            
            return .success(resource)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    var pages: [ArticlePage] {
        
        var pages: [ArticlePage] = Array()
        
        for page in xmlHash["manifest"]["pages"]["article:aem-import"].all {
            if let src = page.element?.attribute(by: "src")?.text {
                let page = ArticlePage(src: src)
                pages.append(page)
            }
        }
        
        return pages
    }
}
