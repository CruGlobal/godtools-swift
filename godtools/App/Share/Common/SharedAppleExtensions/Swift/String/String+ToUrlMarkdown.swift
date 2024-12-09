//
//  String+ToUrlMarkdown.swift
//  godtools
//
//  Created by Levi Eggert on 12/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension String {
    
    func toUrlMarkdown(attributedStringOptions: AttributedString.MarkdownParsingOptions? = nil) -> Result<AttributedString, Error> {
        
        let originalString: String = self
        
        switch originalString.parseUrls() {
            
        case .success(let urls):
            
            let httpsScheme: String = "https://"
            let httpScheme: String = "http://"
            
            var textWithLinks: String = originalString
                    
            for originalUrl in urls {
                
                let displayString: String = originalUrl
                
                var urlLink: String = originalUrl
                 
                let shouldPrefixHttpsScheme: Bool = !urlLink.contains(httpsScheme) && !urlLink.contains(httpScheme)
                             
                if shouldPrefixHttpsScheme {
                    
                    urlLink = httpsScheme + urlLink
                }
                
                textWithLinks = textWithLinks.replacingOccurrences(of: originalUrl, with: "[\(displayString)](\(urlLink))")
            }
                    
            do {
                
                let markdown: AttributedString
                
                if let options = attributedStringOptions {
                    markdown = try AttributedString(markdown: textWithLinks, options: options)
                }
                else {
                    markdown = try AttributedString(markdown: textWithLinks)
                }
                
                return .success(markdown)
            }
            catch let error {
                
                return .failure(error)
            }
            
        case .failure(let parseUrlsError):
            
            return .failure(parseUrlsError)
        }
    }
}
