//
//  AuthTokenBroadcast.swift
//  godtools
//
//  Created by Levi Eggert on 9/2/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

actor AuthTokenBroadcast {
    
    private let stream = MultiBroadcastStream<MobileContentAuthTokenDataModel?>()
    
    init() {
        
    }
    
    func getAuthTokenStream() async -> AsyncStream<MobileContentAuthTokenDataModel?> {
        
        return await stream.getNewStream()
    }
    
    func setAuthToken(authToken: MobileContentAuthTokenDataModel?) async {
        
        await stream.send(value: authToken)
    }
}
