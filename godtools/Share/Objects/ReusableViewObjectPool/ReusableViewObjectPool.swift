//
//  ReusableViewObjectPool.swift
//  godtools
//
//  Created by Levi Eggert on 12/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ReusableViewObjectPool<T: ReusableView> {
    
    private var reusableViews: [T] = Array()
    
    required init() {
        
    }
    
    func addReusableViews(count: Int) {
        for _ in 0 ..< count {
            let reusableView = T()
            returnReusableView(reusableView: reusableView)
        }
    }
    
    func getReusableView() -> T {
        
        let reusableView: T
        
        if !reusableViews.isEmpty {
            reusableView = reusableViews.removeFirst()
        }
        else {
            reusableView = T()
        }
        
        reusableView.resetView()
        
        return reusableView
    }
    
    func returnReusableView(reusableView: T) {
                
        reusableViews.append(reusableView)
    }
}
