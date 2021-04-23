//
//  ToolNavigationPageCell.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ToolNavigationPageCell: UICollectionViewCell {
    
    static let nibName: String = "ToolNavigationPageCell"
    static let reuseIdentifier: String = "ToolNavigationPageCellReuseIdentifier"
    
    private weak var pageViewController: UIViewController?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let pageViewController = self.pageViewController {
            pageViewController.willMove(toParent: nil)
            pageViewController.view.removeFromSuperview()
            pageViewController.removeFromParent()
        }
    }
    
    func configure(pageViewController: UIViewController, parentViewController: UIViewController) {
        
        self.pageViewController = pageViewController
        
        let pageView: UIView = pageViewController.view
        
        parentViewController.addChild(pageViewController)
        contentView.addSubview(pageView)
        pageView.constrainEdgesToSuperview()
        pageViewController.didMove(toParent: parentViewController)
    }
}
