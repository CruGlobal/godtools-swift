//
//  ArticleManifestXmlParser.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ArticleManifestXmlParser: NSObject, ArticleManifestType {
    
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
    
    func getManifestAttributesResult() -> Result<ArticleManifestAttributes, Error> {
        
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
    
    var attributes: ArticleManifestAttributes? {
        switch getManifestAttributesResult() {
        case .success(let attributes):
            return attributes
        case .failure( _):
            return nil
        }
    }
    
    var categories: [ArticleCategory] {
                
        var categories: [ArticleCategory] = Array()
        
        for category in xmlHash["manifest"]["categories"]["category"].all {

            let id: String = category.element?.attribute(by: "id")?.text ?? ""
            let bannerFilename: String = category.element?.attribute(by: "banner")?.text ?? ""
            let title: String = category["label"]["content:text"].element?.text ?? ""
            let bannerSrc: String
            
            switch getResourceResult(filename: bannerFilename) {
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
    
    func getResourceResult(filename: String) -> Result<ArticleResource, Error> {
        
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
    
    func getResource(filename: String) -> ArticleResource? {
                
        switch getResourceResult(filename: filename) {
        case .success(let resource):
            return resource
        case .failure( _):
            return nil
        }
    }

    var aemImportSrcs: [String] {
        
        var urls: [String] = Array()
        
        for articleAemImport in xmlHash["manifest"]["pages"]["article:aem-import"].all {
            if let src = articleAemImport.element?.attribute(by: "src")?.text {
                urls.append(src)
            }
        }
    
        return urls
    }
}
