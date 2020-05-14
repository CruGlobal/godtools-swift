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
    
    func configure(primaryTract: UIView, parallelTract: UIView?, language: TractLanguageType) {
        
        self.primaryTract = primaryTract
        self.parallelTract = parallelTract
        
        contentView.addSubview(primaryTract)
    
        if let parallelTract = parallelTract {
            contentView.addSubview(parallelTract)
            parallelTract.transform = CGAffineTransform(translationX: bounds.size.width, y: 0)
        }
        
        clipsToBounds = true
        
        switch language {
        case .primary:
            showPrimaryTract(animated: false)
        case .parallel:
            showParallelTract(animated: false)
        }
    }
    
    private func showPrimaryTract(animated: Bool) {
        
        let primaryTransform = CGAffineTransform(translationX: 0, y: 0)
        let parallelTransform = CGAffineTransform(translationX: bounds.size.width, y: 0)
        
        if animated {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.primaryTract?.transform = primaryTransform
                self?.parallelTract?.transform = parallelTransform
            }, completion: nil)
        }
        else {
            primaryTract?.transform = primaryTransform
            parallelTract?.transform = parallelTransform
        }
    }
    
    private func showParallelTract(animated: Bool) {
        
        let primaryTransform = CGAffineTransform(translationX: bounds.size.width * -1, y: 0)
        let parallelTransform = CGAffineTransform(translationX: 0, y: 0)
        
        if animated {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.primaryTract?.transform = primaryTransform
                self?.parallelTract?.transform = parallelTransform
            }, completion: nil)
        }
        else {
            primaryTract?.transform = primaryTransform
            parallelTract?.transform = parallelTransform
        }
    }
}
