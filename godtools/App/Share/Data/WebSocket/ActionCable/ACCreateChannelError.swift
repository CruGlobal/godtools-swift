//
//  ACCreateChannelError.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

enum ACCreateChannelError: Error {
    case channelAlreadyCreated
    case isCreatingChannel
    case timedOut
}

extension ACCreateChannelError {
    
    private var errorDescription: String {
        switch self {
        case .channelAlreadyCreated:
            return "Channel is already created."
        case .isCreatingChannel:
            return "Is creating channel"
        case .timedOut:
            return "Timed Out"
        }
    }
    
    func toError() -> Error {
        
        return NSError.errorWithDomain(
            domain: String(describing: ACCreateChannelError.self),
            code: -1,
            description: errorDescription
        )
    }
}
