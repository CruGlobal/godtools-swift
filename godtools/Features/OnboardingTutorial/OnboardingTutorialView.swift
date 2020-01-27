//
//  OnboardingTutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class OnboardingTutorialView: UIViewController {
    
    private let viewModel: OnboardingTutorialViewModelType
    private let pageAnimationOptions: UIView.AnimationOptions = .transitionCrossDissolve
    private let pageAnimationDuration: TimeInterval = 0.2
    
    private var skipButton: UIBarButtonItem?
    private var didLayoutSubviews: Bool = false
    
    @IBOutlet weak private var tutorialCollectionView: UICollectionView!
    @IBOutlet weak private var continueButton: OnboardPrimaryButton!
    @IBOutlet weak private var showMoreButton: OnboardPrimaryButton!
    @IBOutlet weak private var getStartedButton: OnboardPrimaryButton!
    @IBOutlet weak private var pageControl: UIPageControl!
    
    required init(viewModel: OnboardingTutorialViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "OnboardingTutorialView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))\n")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))\n")
                
        setupLayout()
        setupBinding()
        
        pageControl.addTarget(self, action: #selector(handlePageControlChanged), for: .valueChanged)
        
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        showMoreButton.addTarget(self, action: #selector(handleShowMore(button:)), for: .touchUpInside)
        getStartedButton.addTarget(self, action: #selector(handleGetStarted(button:)), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didLayoutSubviews {
            didLayoutSubviews = true
            
            // NOTE: Waiting for view to finish laying out in order for the collection sizeForItem to return the correct bounds size.
            tutorialCollectionView.delegate = self
            tutorialCollectionView.dataSource = self
            
            viewModel.tutorialItems.addObserver(self) { [weak self] (tutorialItems: [OnboardingTutorialItem]) in
                self?.pageControl.numberOfPages = tutorialItems.count
                self?.tutorialCollectionView.reloadData()
            }
            
            viewModel.currentTutorialItemIndex.addObserver(self) { [weak self] (index: Int) in
                
                if let tutorialCollectionView = self?.tutorialCollectionView {
                    let numberOfItems: Int = tutorialCollectionView.numberOfItems(inSection: 0)
                    if numberOfItems > 0 {
                        tutorialCollectionView.scrollToItem(
                            at: IndexPath(item: index, section: 0),
                            at: .centeredHorizontally,
                            animated: true
                        )
                    }
                }
                                
                self?.pageControl.currentPage = index
            }
        }
    }
    
    private func setupLayout() {
        
        tutorialCollectionView.register(
            UINib(nibName: MainOnboardingTutorialCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: MainOnboardingTutorialCell.reuseIdentifier
        )
        tutorialCollectionView.register(
            UINib(nibName: OnboardingTutorialUsageListCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: OnboardingTutorialUsageListCell.reuseIdentifier
        )
        tutorialCollectionView.isScrollEnabled = false
    }
    
    private func setupBinding() {
        
        continueButton.setTitle(viewModel.continueButtonTitle, for: .normal)
        showMoreButton.setTitle(viewModel.showMoreButtonTitle, for: .normal)
        getStartedButton.setTitle(viewModel.getStartedButtonTitle, for: .normal)
        
        viewModel.hidesSkipButton.addObserver(self) { [weak self] (hidden: Bool) in
            
            let skipButtonPosition: ButtonItemPosition = .right
            
            if let view = self {
                if view.skipButton == nil && !hidden {
                    view.skipButton = view.addBarButtonItem(
                        to: skipButtonPosition,
                        title: view.viewModel.skipButtonTitle,
                        color: UIColor(red: 0.231, green: 0.643, blue: 0.859, alpha: 1),
                        target: self,
                        action: #selector(view.handleSkip(barButtonItem:))
                    )
                }
                else if let skipButton = view.skipButton {
                    hidden ? view.removeBarButtonItem(item: skipButton, barPosition: skipButtonPosition) : view.addBarButtonItem(item: skipButton, barPosition: skipButtonPosition)
                }
            }
        }
        
        viewModel.hidesContinueButton.addObserver(self) { [weak self] (hidden: Bool) in
            if let view = self {
                view.setButtonHidden(button: view.continueButton, hidden: hidden, animated: true)
            }
        }
        
        viewModel.hidesShowMoreButton.addObserver(self) { [weak self] (hidden: Bool) in
            if let view = self {
                view.setButtonHidden(button: view.showMoreButton, hidden: hidden, animated: true)
            }
        }
        
        viewModel.hidesGetStartedButton.addObserver(self) { [weak self] (hidden: Bool) in
            if let view = self {
                view.setButtonHidden(button: view.getStartedButton, hidden: hidden, animated: true)
            }
        }
    }
    
    @objc func handleSkip(barButtonItem: UIBarButtonItem) {
        viewModel.skipTapped()
    }
    
    @objc func handlePageControlChanged() {
        viewModel.pageTapped(page: pageControl.currentPage)
    }
    
    @objc func handleContinue(button: UIButton) {
        viewModel.continueTapped()
    }
    
    @objc func handleShowMore(button: UIButton) {
        viewModel.showMoreTapped()
    }
    
    @objc func handleGetStarted(button: UIButton) {
        viewModel.getStartedTapped()
    }
    
    private func setButtonHidden(button: UIButton, hidden: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                button.alpha = hidden ? 0 : 1
            }, completion: nil)
        }
        else {
            button.alpha = hidden ? 0 : 1
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource

extension OnboardingTutorialView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.tutorialItems.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                    
        let tutorialItem: OnboardingTutorialItem = viewModel.tutorialItems.value[indexPath.item]
        
        if let mainTutorialItem = tutorialItem as? MainOnboardingTutorialItem {
            
            let cell = tutorialCollectionView.dequeueReusableCell(
                withReuseIdentifier: MainOnboardingTutorialCell.reuseIdentifier,
                for: indexPath) as! MainOnboardingTutorialCell
                        
            cell.configure(viewModel: MainOnboardingTutorialCellViewModel(item: mainTutorialItem))
            
            return cell
        }
        else if let usageListItem = tutorialItem as? OnboardingTutorialUsageListItem {
            
            let cell = tutorialCollectionView.dequeueReusableCell(
                           withReuseIdentifier: OnboardingTutorialUsageListCell.reuseIdentifier,
                           for: indexPath) as! OnboardingTutorialUsageListCell
                       
            cell.configure(viewModel: OnboardingTutorialUsageListCellViewModel(usageListItem: usageListItem))
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return tutorialCollectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
