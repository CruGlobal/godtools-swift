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
    private let cardPageNavigationView: PageNavigationCollectionView
    private let cardCollectionLayout: HorizontallyCenteredCollectionViewLayout = HorizontallyCenteredCollectionViewLayout()
    private let previousCardButton: UIButton = UIButton(type: .custom)
    private let nextCardButton: UIButton = UIButton(type: .custom)
    private let previousAndNextButtonSize: CGFloat = 44
    private let previousAndNextButtonInsets: CGFloat = 20
    
    private var cards: [MobileContentCardCollectionPageCardView] = Array()
    
    required init(viewModel: MobileContentCardCollectionPageViewModelType) {
        
        self.viewModel = viewModel
        self.cardPageNavigationView = PageNavigationCollectionView(layout: cardCollectionLayout)
        
        super.init(viewModel: viewModel, nibName: nil)
                
        previousCardButton.addTarget(self, action: #selector(previousCardButtonTapped), for: .touchUpInside)
        nextCardButton.addTarget(self, action: #selector(nextCardButtonTapped), for: .touchUpInside)
        
        cardPageNavigationView.delegate = self
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
        addSubview(cardPageNavigationView)
        cardPageNavigationView.translatesAutoresizingMaskIntoConstraints = false
        cardPageNavigationView.constrainEdgesToView(view: self)
    
        cardPageNavigationView.pageBackgroundColor = .clear
        cardPageNavigationView.registerPageCell(classClass: MobileContentCardCollectionPageItemView.self, cellReuseIdentifier: MobileContentCardCollectionPageItemView.reuseIdentifier)
        
        cardCollectionLayout.setCellSize(
            cellSize: .aspectRatioOfContainerWidth(
                aspectRatio: CGSize(width: 182, height: 268),
                containerWidth: frame.size.width,
                widthMultiplier: 0.78
            ),
            cellSpacing: 24
        )

        // previousCardButton
        addSubview(previousCardButton)
        previousCardButton.setImage(ImageCatalog.previousCard.image, for: .normal)
        previousCardButton.translatesAutoresizingMaskIntoConstraints = false
        previousCardButton.constrainLeadingToView(view: self, constant: previousAndNextButtonInsets)
        previousCardButton.constrainBottomToView(view: self, constant: previousAndNextButtonInsets * -1)
        previousCardButton.addWidthConstraint(constant: previousAndNextButtonSize)
        previousCardButton.addHeightConstraint(constant: previousAndNextButtonSize)
        
        // nextButton
        addSubview(nextCardButton)
        nextCardButton.setImage(ImageCatalog.nextCard.image, for: .normal)
        nextCardButton.translatesAutoresizingMaskIntoConstraints = false
        nextCardButton.constrainTrailingToView(view: self, constant: previousAndNextButtonInsets * -1)
        nextCardButton.constrainBottomToView(view: self, constant: previousAndNextButtonInsets * -1)
        nextCardButton.addWidthConstraint(constant: previousAndNextButtonSize)
        nextCardButton.addHeightConstraint(constant: previousAndNextButtonSize)
        
        updatePreviousAndNextButtonVisibility(page: 0)
    }
    
    override func renderChild(childView: MobileContentView) {
        super.renderChild(childView: childView)
        
        if let card = childView as? MobileContentCardCollectionPageCardView {
            cards.append(card)
            cardPageNavigationView.reloadData()
        }
    }
    
    @objc private func previousCardButtonTapped() {
        
        cardPageNavigationView.scrollToPreviousPage(animated: true)
    }
    
    @objc private func nextCardButtonTapped() {
        
        cardPageNavigationView.scrollToNextPage(animated: true)
    }
    
    private func updatePreviousAndNextButtonVisibility(page: Int) {
        
        let isFirstPage: Bool = page == 0
        let isLastPage: Bool = page >= cardPageNavigationView.numberOfPages - 1
        
        let hidesPreviousCardButton: Bool
        let hidesNextCardButton: Bool
        
        if isFirstPage {
            hidesPreviousCardButton = true
            hidesNextCardButton = false
        }
        else if isLastPage {
            hidesPreviousCardButton = false
            hidesNextCardButton = true
        }
        else {
            hidesPreviousCardButton = false
            hidesNextCardButton = false
        }
        
        previousCardButton.isHidden = hidesPreviousCardButton
        nextCardButton.isHidden = hidesNextCardButton
    }
    
    override func getPositionState() -> MobileContentViewPositionState {
        
        let currentPage: Int = cardPageNavigationView.currentPage
                
        return MobileContentCardCollectionPagePositionState(currentPage: currentPage)
    }
    
    override func setPositionState(positionState: MobileContentViewPositionState, animated: Bool) {
        
        guard let cardCollectionPagePositionState = positionState as? MobileContentCardCollectionPagePositionState else {
            return
        }

        let currentPage: Int = cardCollectionPagePositionState.currentPage
        
        cardPageNavigationView.scrollToPage(page: currentPage, animated: animated)        
    }
}

extension MobileContentCardCollectionPageView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        return cards.count
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: MobileContentCardCollectionPageItemView = cardPageNavigationView.getReusablePageCell(
            cellReuseIdentifier: MobileContentCardCollectionPageItemView.reuseIdentifier,
            indexPath: indexPath) as! MobileContentCardCollectionPageItemView
                
        let cardView: MobileContentCardCollectionPageCardView = cards[indexPath.row]
        
        cell.configure(cardView: cardView)
                
        return cell
    }
    
    func pageNavigationPageDidAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        updatePreviousAndNextButtonVisibility(page: page)
        
        viewModel.pageDidAppear(page: page)
    }
    
    func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        updatePreviousAndNextButtonVisibility(page: page)
    }
}
