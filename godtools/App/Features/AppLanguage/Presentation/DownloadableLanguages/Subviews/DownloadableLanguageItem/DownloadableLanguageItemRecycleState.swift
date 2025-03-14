//
//  DownloadableLanguageItemRecycleState.swift
//  godtools
//
//  Created by Levi Eggert on 3/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class DownloadableLanguageItemRecycleState: ObservableObject {
    
    @Published var downloadProgress: Double?
    @Published var downloadError: Error?
    @Published var isMarkedForRemoval: Bool = false
}
