//
//  ShareToolScreenTutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView

class ShareToolScreenTutorialView: UIViewController {
    
    private let viewModel: ShareToolScreenTutorialViewModelType
    
    private var closeButton: UIBarButtonItem?
    private var skipButton: UIBarButtonItem?
    
    @IBOutlet weak private var tutorialPagesView: PageNavigationCollectionView!
    @IBOutlet weak private var continueButton: OnboardPrimaryButton!
    @IBOutlet weak private var pageControl: UIPageControl!
    
    required init(viewModel: ShareToolScreenTutorialViewModelType) {
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
            to: .left,
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
        
        viewModel.tutorialItems.addObserver(self) { [weak self] (tutorialItems: [TutorialItem]) in
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
        
        let buttonPosition: ButtonItemPosition = .right
        
        if skipButton == nil && !hidden {
            
            skipButton = addBarButtonItem(
                to: buttonPosition,
                title: viewModel.skipTitle,
                style: .done,
                color: ColorPalette.gtBlue.color,
                target: self,
                action: #selector(handleSkip(barButtonItem:))
            )
        }
        else if let skipButton = skipButton {
            hidden ? removeBarButtonItem(item: skipButton, barPosition: buttonPosition) : addBarButtonItem(item: skipButton, barPosition: buttonPosition)
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
        
        let tutorialItem: TutorialItem = viewModel.tutorialItems.value[indexPath.item]
        let cellViewModel = TutorialCellViewModel(
            item: tutorialItem,
            customViewBuilder: viewModel.customViewBuilder
        )

        cell.configure(viewModel: cellViewModel, delegate: self)
        
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
    
    func pageNavigationPageDidAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        pageControl.currentPage = page
    }
}

// MARK: - TutorialCellDelegate

extension ShareToolScreenTutorialView: TutorialCellDelegate {
    func tutorialCellVideoPlayer(cell: TutorialCell, didChangeTo state: WKYTPlayerState) {

    }
}
