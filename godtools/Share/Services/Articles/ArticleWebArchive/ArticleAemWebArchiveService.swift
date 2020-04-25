//
//  ArticleAemWebArchiveService.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleAemWebArchiveService {
    
    private let webArchiver: WebArchiveQueue = WebArchiveQueue()
    private let cache: ArticleAemWebArchiveFileCache = ArticleAemWebArchiveFileCache()
    
    required init(resource: DownloadedResource, language: Language) {
        
    }
    
    func archive(urls: [URL]) {
        
        webArchiver.archive(urls: urls, didArchivePlistData: { [weak self] (result: Result<Data?, Error>) in
            
            switch result {
            
            case .success(let plistData):
                if let plistData = plistData {
                    //let location = ArticleAemWebArchiveFileCacheLocation(resource: <#T##DownloadedResource#>, language: <#T##Language#>, filename: <#T##String#>, fileExtension: <#T##String?#>)
                    //self?.cache.cache(location: <#T##FileCacheLocationType#>, data: <#T##Data#>)
                }
            case .failure(let error):
                break
            }
            
        }, complete: { [weak self] in
            
        })
    }
}
