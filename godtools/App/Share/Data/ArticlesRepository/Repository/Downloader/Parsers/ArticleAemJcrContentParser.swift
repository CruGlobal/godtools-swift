//
//  ArticleAemJcrContentParser.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleAemJcrContentParser {
    
    init() {
        
    }
    
    private var supportedTemplates: [String] {
        return ["/conf/cru/settings/wcm/templates/experience-fragment-cru-godtools-variation"]
    }
    
    func parse(aemUri: String, jsonDictionary: [String: Any]) -> ArticleJcrContent? {
                
        return recurseJsonForArticleJcrContent(aemUri: aemUri, jsonDictionary: jsonDictionary)
    }
    
    private func recurseJsonForArticleJcrContent(aemUri: String, jsonDictionary: [String: Any]) -> ArticleJcrContent? {

        for (key, value) in jsonDictionary {
            
            if let childJsonDictionary = value as? [String: Any] {
                                
                if key == "jcr:content", let template = childJsonDictionary["cq:template"] as? String, supportedTemplates.contains(template) {
                                        
                    let canonical: String? = childJsonDictionary["xfCanonical"] as? String
                    let tags: [String] = childJsonDictionary["cq:tags"] as? [String] ?? []
                    let title: String? = childJsonDictionary["jcr:title"] as? String
                    let uuid: String? = childJsonDictionary["jcr:uuid"] as? String
                    
                    let jcrContent = ArticleJcrContent(
                        aemUri: aemUri,
                        canonical: canonical,
                        tags: tags,
                        title: title,
                        uuid: uuid
                    )
                    
                    return jcrContent
                }
                
                return recurseJsonForArticleJcrContent(aemUri: aemUri, jsonDictionary: childJsonDictionary)
            }
        }
        
        return nil
    }
}
