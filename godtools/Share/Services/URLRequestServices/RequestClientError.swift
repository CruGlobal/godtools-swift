//
//  RequestClientError.swift
//  godtools
//
//  Created by Levi Eggert on 2/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct RequestClientError: RequestClientErrorType {
    
    let title: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case message = "message"
    }
}
