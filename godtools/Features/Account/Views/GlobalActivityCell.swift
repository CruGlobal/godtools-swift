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
    
    private let delayCountLabel: BlockBasedTimer = BlockBasedTimer()
    
    @IBOutlet weak private var countLabel: UILabel!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    deinit {
        delayCountLabel.stop()
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
            countLabel.alpha = 0
        }
        else {
            countLabel.alpha = 0
            let randomDelay: Double = Double.random(in: 0.05 ..< 0.75)
            delayCountLabel.start(timeInterval: randomDelay, repeats: false) { [weak self] in
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self?.countLabel.alpha = 1
                    self?.loadingView.alpha = 0
                }) { (finished: Bool) in
                    if finished {
                        self?.loadingView.stopAnimating()
                        self?.loadingView.alpha = 1
                    }
                }
            }
        }
        
//        UIView.transition(with: titleLabel, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
//            self?.titleLabel.text = viewModel.title
//        }, completion: nil)
    }
}
