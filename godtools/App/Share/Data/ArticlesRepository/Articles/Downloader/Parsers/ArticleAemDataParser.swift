//
//  ArticleAemDataParser.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleAemDataParser {
    
    private let articleJcrContentParser: ArticleAemJcrContentParser = ArticleAemJcrContentParser()
    private let errorDomain: String = String(describing: ArticleAemDataParser.self)
    private let forwardSlash: String = "/"
    private let htmlExtension: String = "html"
        
    init() {
        
    }
    
    private func getPrefferedVariationOrder(aemUrl: URL) -> [String] {
        return ["godtools", "godtools-variation", aemUrl.lastPathComponent, "master"]
    }
    
    private func convertAemUrlToHtmlUrlWithVaration(aemUrl: URL, variation: String) -> String {
        
        let aemUrlPathExtension: String = aemUrl.pathExtension
        var aemUrlString: String = aemUrl.absoluteString
        
        if !aemUrlPathExtension.isEmpty {
            aemUrlString = aemUrlString.replacingOccurrences(of: "." + aemUrlPathExtension, with: "")
        }
        
        var htmlUrlString: String
        
        if !variation.isEmpty {
            
            htmlUrlString = aemUrl.absoluteString + forwardSlash + variation.replacingOccurrences(of: forwardSlash, with: "")
        }
        else {
            
            htmlUrlString = aemUrl.absoluteString
        }
        
        htmlUrlString += "." + htmlExtension
        
        htmlUrlString = htmlUrlString.replacingOccurrences(of: "/.\(htmlExtension)", with: ".\(htmlExtension)")
                
        return htmlUrlString
    }
    
    func parse(aemUrl: URL, aemJson: [String: Any]) -> Result<ArticleAemData, ArticleAemDataParserError> {
                     
        let variation: String
        let variationJson: [String: Any]
        
        if let preferredVariation = getPreferredVariation(aemUrl: aemUrl, aemJson: aemJson) {
            
            variation = preferredVariation
            
            guard let variationJsonDictionary = aemJson[preferredVariation] as? [String: Any] else {
                
                let variationJsonError: Error = NSError(
                    domain: errorDomain,
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to parse aem import json result because json for the preferred variation does not exist.\n variation: \(variation)"
                ])
                
                return .failure(.failedToLocateJson(error: variationJsonError))
            }
            
            variationJson = variationJsonDictionary
        }
        else {
            variation = ""
            variationJson = aemJson
        }
                                
        let articleJcrContent: ArticleJcrContent? = articleJcrContentParser.parse(aemUri: aemUrl.absoluteString, jsonDictionary: variationJson)
        
        let aemWebUrl: String = convertAemUrlToHtmlUrlWithVaration(aemUrl: aemUrl, variation: variation)
        
        let aemData = ArticleAemData(
            aemUri: aemUrl.absoluteString,
            articleJcrContent: articleJcrContent,
            webUrl: aemWebUrl,
            updatedAt: Date()
        )
        
        return .success(aemData)
    }
    
    /*
    NOTE:

    The below preferred variatons are root level keys found in the json structure that is getting parsed.

    It appears that each variation can be appended to an aem import src url in order to load an html page per platform.

    For example, take the following aem import src url:

    https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/what-is-christianity/does-god-answer-our-prayers-

    We obtain the json by appending a number representing the maximum amount of levels the json structure will return like so:

    https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/what-is-christianity/does-god-answer-our-prayers-.10.json (10 levels).

    We can also append variations 'master' or ('godtools' or 'godtools-variation') to the import src url to load an html page like so:

    master
    https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/what-is-christianity/does-god-answer-our-prayers-/master.html

    //godtools
    https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/what-is-christianity/does-god-answer-our-prayers-/godtools.html

    //godtools-variation
    https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/what-is-christianity/can-you-explain-the-trinity--/godtools-variation.html
    */
    
    private func getPreferredVariation(aemUrl: URL, aemJson: [String: Any]) -> String? {
           
        let preferredVariationOrder: [String] = getPrefferedVariationOrder(aemUrl: aemUrl)
        
        for variation in preferredVariationOrder {
            
            for (rootKey, _) in aemJson where rootKey == variation {
                
                return rootKey
            }
        }
        
        return nil
    }
}
