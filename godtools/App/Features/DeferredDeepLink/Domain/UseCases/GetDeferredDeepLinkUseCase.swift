//
//  GetDeferredDeepLinkUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetDeferredDeepLinkUseCase {
    
    private let deepLinkService: DeepLinkingService
    private let dynalinkDeferredDeepLink: DynalinkDeferredDeepLink
    private let launchCountRepository: LaunchCountRepositoryInterface
    
    init(deepLinkService: DeepLinkingService, dynalinkDeferredDeepLink: DynalinkDeferredDeepLink, launchCountRepository: LaunchCountRepositoryInterface) {
        
        self.deepLinkService = deepLinkService
        self.dynalinkDeferredDeepLink = dynalinkDeferredDeepLink
        self.launchCountRepository = launchCountRepository
    }
    
    func execute() -> AnyPublisher<ParsedDeepLinkType?, Never> {
         
        let launchCount: Int = launchCountRepository.getLaunchCount()
        
        guard launchCount == 1 else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        
        let deepLinkService: DeepLinkingService = self.deepLinkService
        
        return dynalinkDeferredDeepLink
            .getDeepLinkUrlPublisher()
            .map { (url: URL?) in
                
                guard let url = url else {
                    return nil
                }
                                
                let incomingDeepLink = IncomingDeepLinkUrl(url: url)
                
                let parsedDeepLink = deepLinkService.parseDeepLink(incomingDeepLink: .url(incomingUrl: incomingDeepLink))
                
                return parsedDeepLink
            }
            .catch { (error: Error) in
                return Just(nil)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
