//
//  MobileContentCardCollectionPageView.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class MobileContentCardCollectionPageView: MobileContentPageView {
    
    private let viewModel: MobileContentCardCollectionPageViewModelType
    private let cardCollectionView: UICollectionView
    private let previousCardButton: UIButton = UIButton(type: .custom)
    private let nextCardButton: UIButton = UIButton(type: .custom)
    
    private var cards: [MobileContentCardCollectionPageCardView] = Array()
    
    required init(viewModel: MobileContentCardCollectionPageViewModelType) {
        
        self.viewModel = viewModel
        let cardCollectionLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        cardCollectionLayout.scrollDirection = .horizontal
        self.cardCollectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: cardCollectionLayout)
        
        super.init(viewModel: viewModel, nibName: nil)
                
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(viewModel: MobileContentPageViewModelType, nibName: String?) {
        fatalError("init(viewModel:nibName:) has not been implemented")
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        // cardCollectionView
        addSubview(cardCollectionView)
        cardCollectionView.translatesAutoresizingMaskIntoConstraints = false
        cardCollectionView.constrainEdgesToView(view: self)
        
        cardCollectionView.backgroundColor = .clear
        cardCollectionView.isPagingEnabled = true
        cardCollectionView.register(MobileContentCardCollectionPageCell.self, forCellWithReuseIdentifier: MobileContentCardCollectionPageCell.reuseIdentifier)

        // previousCardButton
        addSubview(previousCardButton)
        previousCardButton.setImage(ImageCatalog.previousCard.image, for: .normal)
        
        // nextButton
        addSubview(nextCardButton)
        nextCardButton.setImage(ImageCatalog.nextCard.image, for: .normal)
    }
    
    override func renderChild(childView: MobileContentView) {
        super.renderChild(childView: childView)
        
        if let card = childView as? MobileContentCardCollectionPageCardView {
            cards.append(card)
            cardCollectionView.reloadData()
        }
    }
}

extension MobileContentCardCollectionPageView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfCards: Int = cards.count
        return numberOfCards
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: MobileContentCardCollectionPageCell = cardCollectionView.dequeueReusableCell(
            withReuseIdentifier: MobileContentCardCollectionPageCell.reuseIdentifier,
            for: indexPath) as! MobileContentCardCollectionPageCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                
        let aspectRatio: CGSize = CGSize(width: 182, height: 268)
        let widthMultiplierOfScreen: CGFloat = 0.84
        
        let width: CGFloat = floor(cardCollectionView.frame.size.width * widthMultiplierOfScreen)
        let height: CGFloat = floor((aspectRatio.height / aspectRatio.width) * width)
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
