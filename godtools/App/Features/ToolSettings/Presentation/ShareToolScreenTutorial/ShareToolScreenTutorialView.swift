//
//  ShareToolScreenTutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ShareToolScreenTutorialView: UIViewController {
    
    private let viewModel: ShareToolScreenTutorialViewModel
    
    private var closeButton: UIBarButtonItem?
    private var skipButton: UIBarButtonItem?
    
    @IBOutlet weak private var tutorialPagesView: PageNavigationCollectionView!
    @IBOutlet weak private var continueButton: OnboardPrimaryButton!
    @IBOutlet weak private var pageControl: UIPageControl!
    
    required init(viewModel: ShareToolScreenTutorialViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: ShareToolScreenTutorialView.self), bundle: nil)
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
            barPosition: .leading,
            index: nil,
            image: ImageCatalog.navClose.uiImage,
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
        
        viewModel.tutorialItems.addObserver(self) { [weak self] (tutorialItems: [TutorialItemType]) in
            self?.pageControl.numberOfPages = tutorialItems.count
            self?.tutorialPagesView.reloadData()
        }
    }
    
    private func handleTutorialPageChange(page: Int) {
        
        pageControl.currentPage = page

        let continueTitle: String
        if tutorialPagesView.isOnLastPage {
            setSkipButton(hidden: true)
            continueTitle = viewModel.shareLinkTitle
        }
        else {
            setSkipButton(hidden: false)
            continueTitle = viewModel.continueTitle
        }

        continueButton.setTitle(continueTitle, for: .normal)
    }
    
    private func setSkipButton(hidden: Bool) {
        
        let buttonPosition: BarButtonItemBarPosition = .trailing
        
        if skipButton == nil && !hidden {
            
            skipButton = addBarButtonItem(
                barPosition: buttonPosition,
                index: nil,
                title: viewModel.skipTitle,
                style: .plain,
                color: ColorPalette.gtBlue.uiColor,
                target: self,
                action: #selector(handleSkip(barButtonItem:))
            )
        }
        else if let skipButton = skipButton {
            hidden ? removeBarButtonItem(item: skipButton) : addBarButtonItem(item: skipButton, barPosition: buttonPosition, index: nil)
        }
    }
    
    @objc func handleClose(barButtonItem: UIBarButtonItem) {
        viewModel.closeTapped()
    }
    
    @objc func handleSkip(barButtonItem: UIBarButtonItem) {
        tutorialPagesView.scrollToLastPage(animated: true)
    }
    
    @objc func handlePageControlChanged() {
        tutorialPagesView.scrollToPage(page: pageControl.currentPage, animated: true)
    }
    
    @objc func handleContinue(button: UIButton) {
        tutorialPagesView.scrollToNextPage(animated: true)
        
        if tutorialPagesView.isOnLastPage {
            viewModel.shareLinkTapped()
        }
    }
}

// MARK: - PageNavigationCollectionViewDelegate

extension ShareToolScreenTutorialView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        return viewModel.tutorialItems.value.count
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: TutorialCell = tutorialPagesView.getReusablePageCell(
            cellReuseIdentifier: TutorialCell.reuseIdentifier,
            indexPath: indexPath) as! TutorialCell
        
        let cellViewModel = viewModel.getTutorialItemViewModel(index: indexPath.item)

        cell.configure(viewModel: cellViewModel)
        
        return cell
    }
    
    func pageNavigationPageDidDisappear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        if let tutorialCell = pageCell as? TutorialCell {
            tutorialCell.stopVideo()
        }
    }
    
    func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {

        handleTutorialPageChange(page: page)
    }
    
    func pageNavigationDidScrollToPage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        pageControl.currentPage = page
    }
}
