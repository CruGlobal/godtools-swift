//
//  GetDeferredDeepLinkUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetDeferredDeepLinkUseCase {
    
    private let deepLinkService: DeepLinkingService
    private let dynalinkDeferredDeepLink: DynalinkDeferredDeepLink
    private let launchCountRepository: LaunchCountRepositoryInterface
    
    init(deepLinkService: DeepLinkingService, dynalinkDeferredDeepLink: DynalinkDeferredDeepLink, launchCountRepository: LaunchCountRepositoryInterface) {
        
        self.deepLinkService = deepLinkService
        self.dynalinkDeferredDeepLink = dynalinkDeferredDeepLink
        self.launchCountRepository = launchCountRepository
    }
    
    func execute() async -> ParsedDeepLinkType? {
         
        let launchCount: Int = launchCountRepository.getLaunchCount()
        
        guard launchCount == 1 else {
            return nil
        }
        
        let url: URL? = await dynalinkDeferredDeepLink.getDeepLinkUrl()
        
        guard let url = url else {
            return nil
        }
        
        let incomingDeepLink = IncomingDeepLinkUrl(url: url)
        
        let parsedDeepLink = deepLinkService.parseDeepLink(incomingDeepLink: .url(incomingUrl: incomingDeepLink))
        
        return parsedDeepLink
    }
}
