//
//  EmailSignUpApiInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol EmailSignUpApiInterface {
    
    func postEmailSignUp(emailSignUp: EmailSignUp, requestPriority: RequestPriority) async throws -> RequestDataResponse
}
