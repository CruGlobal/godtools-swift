//
//  RequestReceiptContainer.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class RequestReceiptContainer<T> {
    
    private var receipts: [RequestReceipt<T>] = Array()
    
    required init() {
        
    }
    
    var isEmpty: Bool {
        return receipts.isEmpty
    }
    
    var first: RequestReceipt<T>? {
        return receipts.first
    }
    
    func add(receipt: RequestReceipt<T>) {
        if !receipts.contains(receipt) {
            receipts.append(receipt)
        }
    }
    
    func remove(receipt: RequestReceipt<T>) {
        if !receipts.isEmpty, let index = receipts.firstIndex(of: receipt) {
            receipts.remove(at: index)
        }
    }
}
