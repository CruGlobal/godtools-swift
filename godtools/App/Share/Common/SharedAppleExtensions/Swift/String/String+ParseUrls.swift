//
//  String+ParseUrls.swift
//  godtools
//
//  Created by Levi Eggert on 12/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension String {
    
    func parseUrls() -> Result<[String], Error> {
        
        let string: String = self
        
        do {
            
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches: [NSTextCheckingResult] = detector.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))

            var urls: [String] = Array()
            
            for match in matches {
                
                guard let range = Range(match.range, in: string) else {
                    continue
                }
                
                let urlString: Substring = string[range]
                
                urls.append(String(urlString))
            }
            
            return .success(urls)
        }
        catch let error {
            
            return .failure(error)
        }
    }
}
