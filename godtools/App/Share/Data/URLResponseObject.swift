//
//  URLResponseObject.swift
//  godtools
//
//  Created by Levi Eggert on 7/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class URLResponseObject {
    
    let data: Data
    let urlResponse: URLResponse
    
    init(data: Data, urlResponse: URLResponse) {
        
        self.data = data
        self.urlResponse = urlResponse
    }
    
    var httpStatusCode: Int? {
        return (urlResponse as? HTTPURLResponse)?.statusCode
    }
    
    var isSuccessHttpStatusCode: Bool {
            
            guard let httpStatusCode = self.httpStatusCode else {
                return false
            }
            
            return httpStatusCode >= 200 && httpStatusCode < 400
        }
}
