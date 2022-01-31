//
//  MobileContentCardCollectionPageItemView.swift
//  godtools
//
//  Created by Levi Eggert on 1/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class MobileContentCardCollectionPageItemView: UICollectionViewCell {
    
    static let nibName: String = "MobileContentCardCollectionPageItemView"
    static let reuseIdentifier: String = "MobileContentCardCollectionPageItemViewReuseIdentifier"
    
    private let cardShadowView: UIView = UIView()
    private let cardBackgroundView: UIView = UIView()
    private let cardContentView: UIView = UIView()
    private let cardCornerRadius: CGFloat = 4
    
    private var cardView: MobileContentCardCollectionPageCardView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cardView?.removeFromSuperview()
        cardView = nil
    }
    
    private func setupLayout() {
        
        // backgroundColor
        backgroundColor = .clear
        
        // contentView
        contentView.backgroundColor = .clear
        
        // cardShadowView
        contentView.addSubview(cardShadowView)
        cardShadowView.translatesAutoresizingMaskIntoConstraints = false
        cardShadowView.constrainEdgesToView(view: contentView)
        cardShadowView.layer.cornerRadius = cardCornerRadius
        cardShadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cardShadowView.layer.shadowRadius = 3
        cardShadowView.layer.shadowColor = UIColor.black.cgColor
        cardShadowView.layer.shadowOpacity = 0.3
        cardShadowView.backgroundColor = .white
        
        // cardBackgroundView
        contentView.addSubview(cardBackgroundView)
        cardBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        cardBackgroundView.constrainEdgesToView(view: contentView)
        cardBackgroundView.layer.cornerRadius = cardCornerRadius
        cardBackgroundView.backgroundColor = .white
        
        // cardContentView
        contentView.addSubview(cardContentView)
        cardContentView.translatesAutoresizingMaskIntoConstraints = false
        cardContentView.constrainEdgesToView(view: contentView)
        cardContentView.backgroundColor = .clear
    }
    
    func configure(cardView: MobileContentCardCollectionPageCardView) {
        
        cardContentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.constrainEdgesToView(view: cardContentView)
        
        self.cardView = cardView
    }
}
