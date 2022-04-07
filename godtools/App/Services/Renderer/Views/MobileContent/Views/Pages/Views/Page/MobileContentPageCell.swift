//
//  MobileContentPageCell.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentPageCell: UICollectionViewCell {
    
    static let nibName: String = "MobileContentPageCell"
    static let reuseIdentifier: String = "MobileContentPageCellReuseIdentifier"
     
    private(set) var mobileContentView: MobileContentView?
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mobileContentView?.removeFromSuperview()
        mobileContentView = nil
    }
    
    func configure(mobileContentView: MobileContentView) {
        
        contentView.addSubview(mobileContentView)
        mobileContentView.translatesAutoresizingMaskIntoConstraints = false
        mobileContentView.constrainEdgesToView(view: contentView)
        
        self.mobileContentView = mobileContentView
    }
}
