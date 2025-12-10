//
//  TrackDownloadedTranslationsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class TrackDownloadedTranslationsRepository {
    
    let cache: TrackDownloadedTranslationsCache
    
    init(cache: TrackDownloadedTranslationsCache) {
        
        self.cache = cache
    }
}
