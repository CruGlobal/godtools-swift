//
//  ShareToolRemoteSessionURLViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ShareToolRemoteSessionURLViewModel: ShareToolRemoteSessionURLViewModelType {
        
    let shareMessage: String
    
    required init(toolRemoteShareUrl: URL, localizationServices: LocalizationServices) {
                
        shareMessage = String.localizedStringWithFormat(
            localizationServices.stringForMainBundle(key: "share_tool_remote_link_message"),
            toolRemoteShareUrl.absoluteString
        )
    }
}
