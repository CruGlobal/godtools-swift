//
//  TractPagination.swift
//  godtools
//
//  Created by Pablo Marti on 6/2/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

class TractPagination {
    
    var pageNumber: Int = 1
    var totalPages: Int = 1
    
    init(totalPages: Int, pageNumber: Int) {
        self.totalPages = totalPages
        self.pageNumber = pageNumber
    }
    
    func didReachEnd() -> Bool {
        return self.totalPages == self.pageNumber
    }
    
}
