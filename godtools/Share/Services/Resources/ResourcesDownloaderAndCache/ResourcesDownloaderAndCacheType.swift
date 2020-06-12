//
//  ResourcesDownloaderAndCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ResourcesDownloaderAndCacheType {
    
    associatedtype T = Any
    
    var isDownloadingResources: Bool { get }
    var currentRequestReceipt: RequestReceipt<T>? { get }
    
    func downloadAndCacheLanguagesPlusResourcesPlusLatestTranslationsAndAttachments() -> RequestReceipt<T>
}
