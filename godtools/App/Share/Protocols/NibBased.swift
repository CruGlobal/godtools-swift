//
//  NibBased.swift
//  godtools
//
//  Created by Levi Eggert on 1/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol NibBased: AnyObject {
    static var nib: UINib { get }
}

extension NibBased {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

extension NibBased where Self: UIView {
    
    func loadNib() {
        
        let contents: [Any]? = Self.nib.instantiate(withOwner: self, options: nil)
        
        if let views = contents as? [UIView] {
            
            if let rootView = views.first {
                                
                addSubview(rootView)
                rootView.frame = bounds
                rootView.constrainEdgesToSuperview()
                
                constrainEdgesToSuperview()
            }
        }
    }
}
