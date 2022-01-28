//
//  MobileContentCardCollectionPageCell.swift
//  godtools
//
//  Created by Levi Eggert on 1/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class MobileContentCardCollectionPageCell: UICollectionViewCell {
    
    static let nibName: String = "MobileContentCardCollectionPageCell"
    static let reuseIdentifier: String = "MobileContentCardCollectionPageCellReuseIdentifier"
    
    private let cardShadowView: UIView = UIView()
    private let cardBackgroundView: UIView = UIView()
    private let cardContentView: UIView = UIView()
    private let cardCornerRadius: CGFloat = 12
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func setupLayout() {
        
        // backgroundColor
        backgroundColor = .clear
        
        // contentView
        contentView.backgroundColor = .clear
        contentView.drawBorder(color: .red)
        
        // cardShadowView
        contentView.addSubview(cardShadowView)
        cardShadowView.translatesAutoresizingMaskIntoConstraints = false
        cardShadowView.constrainEdgesToView(view: contentView)
        cardShadowView.layer.cornerRadius = cardCornerRadius
        
        // cardBackgroundView
        contentView.addSubview(cardBackgroundView)
        cardBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        cardBackgroundView.constrainEdgesToView(view: contentView)
        cardBackgroundView.layer.cornerRadius = cardCornerRadius
        
        // cardContentView
        contentView.addSubview(cardContentView)
        cardContentView.translatesAutoresizingMaskIntoConstraints = false
        cardContentView.constrainEdgesToView(view: contentView)
    }
}
