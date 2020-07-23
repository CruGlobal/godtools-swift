//
//  TractPageCell.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TractPageCell: UICollectionViewCell {
    
    static let nibName: String = "TractPageCell"
    static let reuseIdentifier: String = "TractPageCellReuseIdentifier"
        
    private weak var primaryTract: UIView?
    private weak var parallelTract: UIView?
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func setTractPage(tractPage: TractPage) {
        
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        
        if let renderedView = tractPage.renderedView {
           contentView.addSubview(renderedView)
        }
    }
}
