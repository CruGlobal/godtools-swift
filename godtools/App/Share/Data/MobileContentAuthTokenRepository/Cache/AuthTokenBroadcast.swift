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
    
    private var authToken: MobileContentAuthTokenDataModel?
    
    init() {
        
    }
    
    func getAuthTokenStream() async -> AsyncStream<MobileContentAuthTokenDataModel?> {
        
        return await stream.getNewStream(sendValue: authToken)
    }
    
    func setAuthToken(authToken: MobileContentAuthTokenDataModel?) async {
        
        self.authToken = authToken
        
        await stream.send(value: authToken)
    }
}
