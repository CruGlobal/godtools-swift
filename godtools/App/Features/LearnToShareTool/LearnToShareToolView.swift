//
//  LearnToShareToolView.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class LearnToShareToolView: UIViewController {
    
    private let viewModel: LearnToShareToolViewModelType
    
    private var backButton: UIBarButtonItem?
    private var closeButton: UIBarButtonItem?
            
    @IBOutlet weak private var learnToShareToolPagesView: PageNavigationCollectionView!
    @IBOutlet weak private var continueButton: OnboardPrimaryButton!
    @IBOutlet weak private var pageControl: UIPageControl!
    
    required init(viewModel: LearnToShareToolViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: LearnToShareToolView.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
        
        setupLayout()
        setupBinding()
        
        closeButton = addBarButtonItem(
            to: .right,
            image: UIImage(named: "nav_item_close"),
            color: nil,
            target: self,
            action: #selector(handleClose(barButtonItem:))
        )
        
        pageControl.addTarget(self, action: #selector(handlePageControlChanged), for: .valueChanged)
        
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        
        learnToShareToolPagesView.delegate = self
    }
    
    private func setupLayout() {
        
        // tutorialPagesView
        learnToShareToolPagesView.registerPageCell(
            nib: UINib(nibName: LearnToShareToolCell.nibName, bundle: nil),
            cellReuseIdentifier: LearnToShareToolCell.reuseIdentifier
        )
        
        handlePageChange(page: 0)
    }
    
    private func setupBinding() {
        
        viewModel.numberOfLearnToShareToolItems.addObserver(self) { [weak self] (numberOfLearnToShareToolItems: Int) in
            self?.pageControl.numberOfPages = numberOfLearnToShareToolItems
            self?.learnToShareToolPagesView.reloadData()
        }
    }
    
    private func handlePageChange(page: Int) {
        
        pageControl.currentPage = page
        
        setBackButton(hidden: page == 0)
              
        let continueTitle: String
        if learnToShareToolPagesView.isOnLastPage {
            continueTitle = viewModel.startTrainingTitle
        }
        else {
            continueTitle = viewModel.continueTitle
        }
        
        continueButton.setTitle(continueTitle, for: .normal)
    }
    
    private func setBackButton(hidden: Bool) {
        
        let backButtonPosition: ButtonItemPosition = .left
        
        if backButton == nil && !hidden {
            backButton = addBarButtonItem(
                to: backButtonPosition,
                image: ImageCatalog.navBack.uiImage,
                color: nil,
                target: self,
                action: #selector(handleBack(barButtonItem:))
            )
        }
        else if let backButton = backButton {
            hidden ? removeBarButtonItem(item: backButton, barPosition: backButtonPosition) : addBarButtonItem(item: backButton, barPosition: backButtonPosition)
        }
    }
    
    @objc func handleBack(barButtonItem: UIBarButtonItem) {
        learnToShareToolPagesView.scrollToPreviousPage(animated: true)
    }
    
    @objc func handleClose(barButtonItem: UIBarButtonItem) {
        viewModel.closeTapped()
    }
    
    @objc func handlePageControlChanged() {
        learnToShareToolPagesView.scrollToPage(page: pageControl.currentPage, animated: true)
    }
    
    @objc func handleContinue(button: UIButton) {
        learnToShareToolPagesView.scrollToNextPage(animated: true)
        viewModel.continueTapped()
    }
}

// MARK: - PageNavigationCollectionViewDelegate

extension LearnToShareToolView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        return viewModel.numberOfLearnToShareToolItems.value
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: LearnToShareToolCell = learnToShareToolPagesView.getReusablePageCell(
            cellReuseIdentifier: LearnToShareToolCell.reuseIdentifier,
            indexPath: indexPath
        ) as! LearnToShareToolCell
        
        let cellViewModel: LearnToShareToolCellViewModelType = viewModel.willDisplayLearnToShareToolPage(index: indexPath.row)
        
        cell.configure(viewModel: cellViewModel)
        
        return cell
    }
    
    func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {

        handlePageChange(page: page)
        
        viewModel.pageDidChange(page: page)
    }
    
    func pageNavigationPageDidAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        pageControl.currentPage = page
        
        viewModel.pageDidAppear(page: page)
    }
}
