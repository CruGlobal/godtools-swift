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
    
    private var didLayoutSubviews: Bool = false
    
    @IBOutlet weak private var tutorialCollectionView: UICollectionView!
    @IBOutlet weak private var continueButton: OnboardPrimaryButton!
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
        
        viewModel.continueTitle.addObserver(self) { [weak self] (title: String) in
            self?.continueButton.setTitle(title, for: .normal)
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
