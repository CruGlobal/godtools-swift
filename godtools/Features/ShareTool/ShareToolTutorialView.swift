//
//  ShareToolTutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ShareToolTutorialView: UIViewController {
    
    private let viewModel: ShareToolTutorialViewModelType
    
    private var backButton: UIBarButtonItem?
    private var closeButton: UIBarButtonItem?
    
    @IBOutlet weak private var tutorialPagesView: PageNavigationCollectionView!
    @IBOutlet weak private var continueButton: OnboardPrimaryButton!
    @IBOutlet weak private var pageControl: UIPageControl!
    
    required init(viewModel: ShareToolTutorialViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: TutorialView.self), bundle: nil)
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
        
        tutorialPagesView.delegate = self
    }
    
    private func setupLayout() {
        
        // tutorialPagesView
        tutorialPagesView.registerPageCell(
            nib: UINib(nibName: TutorialCell.nibName, bundle: nil),
            cellReuseIdentifier: TutorialCell.reuseIdentifier
        )
        
        handleTutorialPageChange(page: 0)
    }
    
    private func setupBinding() {
        
//        viewModel.tutorialItems.addObserver(self) { [weak self] (tutorialItems: [TutorialItem]) in
//            self?.pageControl.numberOfPages = tutorialItems.count
//            self?.tutorialPagesView.reloadData()
//        }
    }
    
    private func handleTutorialPageChange(page: Int) {
        
//        pageControl.currentPage = page
//
//        setBackButton(hidden: page == 0)
//
//        let continueTitle: String
//        if tutorialPagesView.isOnLastPage {
//            continueTitle = viewModel.startUsingGodToolsTitle
//        }
//        else {
//            continueTitle = viewModel.continueTitle
//        }
//
//        continueButton.setTitle(continueTitle, for: .normal)
    }
    
    private func setBackButton(hidden: Bool) {
        
        let backButtonPosition: ButtonItemPosition = .left
        
        if backButton == nil && !hidden {
            backButton = addBarButtonItem(
                to: backButtonPosition,
                image: UIImage(named: "nav_item_back"),
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
        tutorialPagesView.scrollToPreviousPage(animated: true)
    }
    
    @objc func handleClose(barButtonItem: UIBarButtonItem) {
        viewModel.closeTapped()
    }
    
    @objc func handlePageControlChanged() {
        tutorialPagesView.scrollToPage(page: pageControl.currentPage, animated: true)
    }
    
    @objc func handleContinue(button: UIButton) {
        tutorialPagesView.scrollToNextPage(animated: true)
        viewModel.continueTapped()
    }
}

// MARK: - PageNavigationCollectionViewDelegate

extension ShareToolTutorialView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        return 0//return viewModel.tutorialItems.value.count
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: TutorialCell = tutorialPagesView.getReusablePageCell(
            cellReuseIdentifier: TutorialCell.reuseIdentifier,
            indexPath: indexPath) as! TutorialCell
        
//        let tutorialItem: TutorialItem = viewModel.tutorialItems.value[indexPath.item]
//        let cellViewModel = TutorialCellViewModel(
//            item: tutorialItem,
//            deviceLanguage: viewModel.deviceLanguage
//        )
//
//        cell.configure(viewModel: cellViewModel, delegate: self)
        
        return cell
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, willDisplay pageCell: UICollectionViewCell, forPageAt indexPath: IndexPath) {

    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, didEndDisplaying pageCell: UICollectionViewCell, forPageAt indexPath: IndexPath) {
        if let tutorialCell = pageCell as? TutorialCell {
            tutorialCell.stopVideo()
        }
    }
    
    func pageNavigationDidChangePage(pageNavigation: PageNavigationCollectionView, page: Int) {

        handleTutorialPageChange(page: page)
        
        viewModel.pageDidChange(page: page)
    }
    
    func pageNavigationDidStopOnPage(pageNavigation: PageNavigationCollectionView, page: Int) {
        
        pageControl.currentPage = page
        
        viewModel.pageDidAppear(page: page)
    }
}
