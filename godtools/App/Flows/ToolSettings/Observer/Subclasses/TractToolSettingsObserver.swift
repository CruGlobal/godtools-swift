//
//  CYOAToolSettingsObserver.swift
//  godtools
//
//  Created by Rachael Skeath on 8/6/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class TractToolSettingsObserver: ToolSettingsObserver, RemoteShareable, LinkShareable {
    
    let tractRemoteSharePublisher: TractRemoteSharePublisher
    
    init(
        toolId: String,
        languages: ToolSettingsLanguages,
        pageNumber: Int,
        trainingTipsEnabled: Bool,
        tractRemoteSharePublisher: TractRemoteSharePublisher
    ) {
        
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        
        super.init(
            toolId: toolId,
            languages: languages,
            pageNumber: pageNumber,
            subPageNumber: nil,
            trainingTipsEnabled: trainingTipsEnabled
        )
    }
}
