//
//  URLResponseError.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum URLResponseError: Error {

    case decodeError(error: Error)
    case otherError(error: Error)
    case requestError(error: Error)
    case statusCode(urlResponseObject: URLResponseObject)
}
