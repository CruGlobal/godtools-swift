//
//  GlobalActivityCell.swift
//  godtools
//
//  Created by Levi Eggert on 2/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class GlobalActivityCell: UICollectionViewCell {
    
    static let nibName: String = "GlobalActivityCell"
    static let reuseIdentifier: String = "GlobalActivityCellReuseIdentifier"
        
    @IBOutlet weak private var countLabel: UILabel!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    private func setupLayout() {
        
        //drawShadow
        backgroundColor = UIColor.white
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 4
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        clipsToBounds = false
        layer.cornerRadius = 10
    }
    
    func configure(viewModel: GlobalActivityCellViewModel) {
        
        countLabel.text = viewModel.count
        titleLabel.text = viewModel.title
        
        if viewModel.isLoading {
            loadingView.alpha = 1
            loadingView.startAnimating()
        }
        else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.loadingView.alpha = 0
            }) { [weak self] (finished: Bool) in
                if finished {
                    self?.loadingView.stopAnimating()
                    self?.loadingView.alpha = 1
                }
            }
        }
    }
}
