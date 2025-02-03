//
//  MobileContentPageCollectionView.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit

class MobileContentPageCollectionView: MobileContentPageView {
    
    private let viewModel: MobileContentPageCollectionViewModel
    private let pageNavigationView: PageNavigationCollectionView
    
    init(viewModel: MobileContentPageCollectionViewModel) {
        
        self.viewModel = viewModel
        
        pageNavigationView = PageNavigationCollectionView(layoutType: .fullScreen)
        
        super.init(viewModel: viewModel, nibName: nil)
        
        pageNavigationView.setDelegate(delegate: self)
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupLayout() {
        super.setupLayout()
                        
        // pageNavigationView
        addSubview(pageNavigationView)
        pageNavigationView.translatesAutoresizingMaskIntoConstraints = false
        pageNavigationView.constrainEdgesToView(view: self)
        
        pageNavigationView.setSemanticContentAttribute(semanticContentAttribute: viewModel.layoutDirection.semanticContentAttribute)
    
        pageNavigationView.pageBackgroundColor = .clear
        pageNavigationView.registerPageCell(
            classClass: MobileContentPageCell.self,
            cellReuseIdentifier: MobileContentPageCell.reuseIdentifier
        )
    }
}

extension MobileContentPageCollectionView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        return viewModel.numberOfPages
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = pageNavigationView.getReusablePageCell(
            cellReuseIdentifier: MobileContentPageCell.reuseIdentifier,
            indexPath: indexPath) as? MobileContentPageCell else {
            
            assertionFailure("Failed to dequeue reusable cell with identifier :\(MobileContentPageCell.reuseIdentifier)")
            
            return UICollectionViewCell()
        }
        
        if let pageView = viewModel.pageWillAppear(page: indexPath.row) {
            cell.configure(mobileContentView: pageView)
        }
        else {
            assertionFailure("Failed to render MobileContentView.")
        }
                                
        return cell
    }
    
    func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
    }
    
    func pageNavigationDidScrollToPage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
                
        viewModel.pageDidAppear(page: page)
    }
}
