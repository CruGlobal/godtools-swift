//
//  ShareToolQRCodeUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/22/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class ShareToolQRCodeUseCase {
    
    private let getShareToolUrl: GetShareToolUrl
    
    init(getShareToolUrl: GetShareToolUrl) {
        
        self.getShareToolUrl = getShareToolUrl
    }
    
    func execute(toolId: String, toolLanguageId: String, pageNumber: Int) throws -> ShareToolQRCodeDomainModel {
        
        let urlString: String? = getShareToolUrl.getUrl(
            toolId: toolId,
            toolLanguageId: toolLanguageId,
            pageNumber: pageNumber
        )
        
        guard let urlString = urlString, !urlString.isEmpty else {
            throw NSError.errorWithDescription(description: "Failed to get share tool url.")
        }
        
        return ShareToolQRCodeDomainModel(url: urlString)
    }
}
