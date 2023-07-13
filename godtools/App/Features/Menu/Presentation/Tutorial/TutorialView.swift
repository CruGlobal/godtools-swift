//
//  TutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

// TODO: Look into using TutorialPagerView instead. ~Levi
class TutorialView: UIViewController {

    private let viewModel: TutorialViewModelType
    
    private var backButton: UIBarButtonItem?
    private var closeButton: UIBarButtonItem?
    
    @IBOutlet weak private var tutorialPagesView: PageNavigationCollectionView!
    @IBOutlet weak private var continueButton: OnboardPrimaryButton!
    @IBOutlet weak private var pageControl: UIPageControl!
    
    required init(viewModel: TutorialViewModelType) {
        
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
            image: ImageCatalog.navClose.uiImage,
            color: nil,
            target: self,
            action: #selector(closeButtonTapped)
        )
        
        pageControl.addTarget(self, action: #selector(pageControlTapped), for: .valueChanged)
        
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        tutorialPagesView.delegate = self
        
        tutorialPagesView.scrollToPage(
            pageNavigation: PageNavigationCollectionViewNavigationModel(
                navigationDirection: .forceLeftToRight,
                page: 0,
                animated: false,
                reloadCollectionViewDataNeeded: false,
                insertPages: nil
            )
        )
    }
    
    private func setupLayout() {
        
        // tutorialPagesView
        tutorialPagesView.registerPageCell(
            nib: UINib(nibName: TutorialCell.nibName, bundle: nil),
            cellReuseIdentifier: TutorialCell.reuseIdentifier
        )
    }
    
    private func setupBinding() {
        
        viewModel.hidesBackButton.addObserver(self) { [weak self] (value: Bool) in
            self?.setBackButton(hidden: value)
        }
        
        viewModel.currentPage.addObserver(self) { [weak self] (value: Int) in
            self?.pageControl.currentPage = value
        }
        
        viewModel.numberOfPages.addObserver(self) { [weak self] (value: Int) in
            self?.pageControl.numberOfPages = value
            self?.tutorialPagesView.reloadData()
        }
        
        viewModel.continueTitle.addObserver(self) { [weak self] (value: String) in
            self?.continueButton.setTitle(value, for: .normal)
        }
    }
    
    private func setBackButton(hidden: Bool) {
        
        let backButtonPosition: BarButtonItemBarPosition = .left
        
        if backButton == nil && !hidden {
            backButton = addBarButtonItem(
                to: backButtonPosition,
                image: ImageCatalog.navBack.uiImage,
                color: nil,
                target: self,
                action: #selector(backButtonTapped)
            )
        }
        else if let backButton = backButton {
            
            hidden ? removeBarButtonItem(item: backButton) : addBarButtonItem(item: backButton, barPosition: backButtonPosition)
        }
    }
    
    @objc private func backButtonTapped() {
        tutorialPagesView.scrollToPreviousPage(animated: true)
    }
    
    @objc private func closeButtonTapped() {
        viewModel.closeTapped()
    }
    
    @objc private func pageControlTapped() {
        tutorialPagesView.scrollToPage(page: pageControl.currentPage, animated: true)
    }
    
    @objc private func continueButtonTapped() {
        tutorialPagesView.scrollToNextPage(animated: true)
        viewModel.continueTapped()
    }
}

// MARK: - PageNavigationCollectionViewDelegate

extension TutorialView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        return viewModel.numberOfPages.value
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: TutorialCell = tutorialPagesView.getReusablePageCell(
            cellReuseIdentifier: TutorialCell.reuseIdentifier,
            indexPath: indexPath) as! TutorialCell
        
        let cellViewModel = viewModel.tutorialPageWillAppear(index: indexPath.item)
        
        cell.configure(viewModel: cellViewModel)
        
        return cell
    }
    
    func pageNavigationPageDidDisappear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        if let tutorialCell = pageCell as? TutorialCell {
            tutorialCell.stopVideo()
        }
    }
    
    func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        viewModel.pageDidChange(page: page)
    }
    
    func pageNavigationPageDidAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
                
    }
    
    func pageNavigationDidEndPageScrolling(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        viewModel.pageDidAppear(page: page)
    }
}
