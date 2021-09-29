//
//  TutorialPagerView.swift
//  godtools
//
//  Created by Robert Eldredge on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class TutorialPagerView: UIViewController {
    
    private let viewModel: TutorialPagerViewModelType
    
    private var skipButton: UIBarButtonItem?
    
    @IBOutlet weak private var footerView: UIView!
    @IBOutlet weak private var tutorialPagesView: PageNavigationCollectionView!
    @IBOutlet weak private var continueButton: OnboardPrimaryButton!
    @IBOutlet weak private var pageControl: UIPageControl!
    
    @IBOutlet weak private var continueButtonTop: NSLayoutConstraint!
    @IBOutlet weak private var footerAreaHeight: NSLayoutConstraint!
    
    required init(viewModel: TutorialPagerViewModelType) {
        
        self.viewModel = viewModel
        super.init(nibName: String(describing: TutorialPagerView.self), bundle: nil)
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
        
        pageControl.addTarget(self, action: #selector(handlePageControlChanged), for: .valueChanged)
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        
        tutorialPagesView.delegate = self
    }
    
    private func setupLayout() {
        
        tutorialPagesView.pageBackgroundColor = .clear
        tutorialPagesView.registerPageCell(nib: UINib(nibName: TutorialPagerCell.nibName, bundle: nil), cellReuseIdentifier: TutorialPagerCell.reuseIdentifier)
        
        handleTutorialPageChange(page: 0)
    }
    
    private func setupBinding() {
        
        pageControl.numberOfPages = viewModel.pageCount
        
        viewModel.page.addObserver(self) { [weak self] (page: Int) in
            self?.pageControl.currentPage = page
        }
        
        
        viewModel.skipButtonHidden.addObserver(self) { [weak self] (hidden: Bool) in
            self?.setSkipButton(hidden: hidden)
        }
        
        viewModel.continueButtonTitle.addObserver(self) { [weak self] (title: String) in
            self?.continueButton.setTitle(title, for: .normal)
        }
        
        viewModel.footerHidden.addObserver(self) { [weak self] (hidden: Bool) in
            self?.footerView.isHidden = hidden
        }
    }
    
    private func reloadData() {
        
        tutorialPagesView.reloadData()
    }
    
    private func handleTutorialPageChange(page: Int) {
        
        setContinueButton(animated: true)
    }
    
    private func setSkipButton(hidden: Bool) {
        
        let skipButtonPosition: ButtonItemPosition = .right
        
        if skipButton == nil {
            if !hidden {
                skipButton = addBarButtonItem(
                    to: skipButtonPosition,
                    title: viewModel.skipButtonTitle,
                    style: .plain,
                    color: UIColor(red: 0.231, green: 0.643, blue: 0.859, alpha: 1),
                    target: self,
                    action: #selector(handleSkip(barButtonItem:))
                )
            }
        }
        else if let skipButton = skipButton {
            hidden ? removeBarButtonItem(item: skipButton, barPosition: skipButtonPosition) : addBarButtonItem(item: skipButton, barPosition: skipButtonPosition)
        }
    }
    
    private func setContinueButton(animated: Bool) {
        
        let layoutView: UIView = footerView
        let animationDuration: TimeInterval = 0.28
        let visible: CGFloat = 0
        
        if animated {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
                layoutView.layoutIfNeeded()
            })
        } else {
            layoutView.layoutIfNeeded()
        }
        
        continueButtonTop.constant = visible
        continueButton.alpha = 1
        if animated {
            UIView.animate(withDuration: animationDuration, delay: 0.14, options: .curveEaseOut, animations: {
                layoutView.layoutIfNeeded()
            }, completion: nil)
        } else {
            layoutView.layoutIfNeeded()
        }
    }
    
    @objc func handleSkip(barButtonItem: UIBarButtonItem) {
        
        viewModel.skipTapped()
    }
    
    @objc func handlePageControlChanged() {
        
        tutorialPagesView.scrollToPage(page: pageControl.currentPage, animated: true)
    }
    
    @objc func handleContinue() {
        
        tutorialPagesView.scrollToNextPage(animated: true)
        
        viewModel.continueTapped()
    }
}

//MARK: -- PageNavigationCollectionViewDelegate

extension TutorialPagerView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        return viewModel.pageCount
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = tutorialPagesView.getReusablePageCell(cellReuseIdentifier: TutorialPagerCell.reuseIdentifier, indexPath: indexPath) as! TutorialPagerCell
        
        let cellViewModel = viewModel.tutorialItemWillAppear(index: indexPath.item)
        cell.configure(viewModel: cellViewModel)
        
        return cell
    }
    
    func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        if pageNavigation == tutorialPagesView {
            
            handleTutorialPageChange(page: page)
            
            viewModel.pageDidChange(page: page)
        }
    }
    
    func pageNavigationPageDidAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        if pageNavigation == tutorialPagesView {
            
            viewModel.pageDidAppear(page: page)
        }
    }
}
