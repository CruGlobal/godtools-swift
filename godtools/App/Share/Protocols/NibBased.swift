//
//  NibBased.swift
//  godtools
//
//  Created by Levi Eggert on 1/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol NibBased: AnyObject {
    static var nibName: String { get }
}

extension NibBased {
    
    static var nibName: String {
        return String(describing: self)
    }
}

extension NibBased where Self: UIView {
    
    @discardableResult func loadNib(nibName: String = Self.nibName) -> UIView? {
        
        let nib: UINib = UINib(nibName: nibName, bundle: nil)
        
        guard let contents = nib.instantiate(withOwner: self, options: nil) as? [UIView] else {
            assertionFailure("\n WARNING: Failed to load top level UIView objects from nib with nibName: \(nibName)")
            return nil
        }
        
        guard let rootNibView = contents.first else {
            
            assertionFailure("\n WARNING: Top level object does not contain any child elements on nib with nibName: \(nibName)")
            return nil
        }
        
        addSubview(rootNibView)
        rootNibView.frame = bounds
        rootNibView.translatesAutoresizingMaskIntoConstraints = false
        rootNibView.constrainEdgesToView(view: self)
        rootNibView.backgroundColor = .clear
                
        return rootNibView
    }
}
