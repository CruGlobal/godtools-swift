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
}
