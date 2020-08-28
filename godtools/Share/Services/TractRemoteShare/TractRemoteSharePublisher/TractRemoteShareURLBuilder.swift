//
//  TractRemoteShareURLBuilder.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

// Example url: https: //knowgod.com/de/kgp?icid=gtshare&primaryLanguage=en&parallelLanguage=de&liveShareStream=9cae02af93e1d510c3e0-1597355635

class TractRemoteShareURLBuilder {
    
    required init() {
        
    }
    
    func buildRemoteShareURL(resource: ResourceModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, subscriberChannelId: String) -> URL? {
        
        var shareUrlString: String = ""
        
        shareUrlString += "https://knowgod.com"
        shareUrlString += "/" + primaryLanguage.code
        shareUrlString += "/" + resource.abbreviation
        shareUrlString += "?icid=gtshare"
        shareUrlString += "&primaryLanguage=\(primaryLanguage.code)"
        if let parallelLanguage = parallelLanguage {
            shareUrlString += "&parallelLanguage=\(parallelLanguage.code)"
        }
        shareUrlString += "&liveShareStream=\(subscriberChannelId)"
        
        return URL(string: shareUrlString)
    }
}
