//
//  TutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TutorialView: UIViewController {
    
    private let viewModel: TutorialViewModelType
    
    private var closeButton: UIBarButtonItem?
    private var didLayoutSubviews: Bool = false
    
    @IBOutlet weak private var tutorialCollectionView: UICollectionView!
    @IBOutlet weak private var continueButton: OnboardPrimaryButton!
    @IBOutlet weak private var pageControl: UIPageControl!
    
    required init(viewModel: TutorialViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "TutorialView", bundle: nil)
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
        
        addDefaultNavBackItem()
        
        closeButton = addBarButtonItem(
            to: .right,
            image: UIImage(named: "nav_item_close"),
            color: nil,
            target: self,
            action: #selector(handleClose(barButtonItem:))
        )
        
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
            
            viewModel.tutorialItems.addObserver(self) { [weak self] (tutorialItems: [TutorialItem]) in
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
            UINib(nibName: TutorialCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: TutorialCell.reuseIdentifier
        )
        tutorialCollectionView.isScrollEnabled = false
    }
    
    private func setupBinding() {
        
        viewModel.continueButtonTitle.addObserver(self) { [weak self] (title: String) in
            self?.continueButton.setTitle(title, for: .normal)
        }
    }
    
    @objc func handleClose(barButtonItem: UIBarButtonItem) {
        viewModel.closeTapped()
    }
    
    @objc func handlePageControlChanged() {
        viewModel.pageTapped(page: pageControl.currentPage)
    }
    
    @objc func handleContinue(button: UIButton) {
        viewModel.continueTapped()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource

extension TutorialView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.tutorialItems.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                    
        let cell: TutorialCell = tutorialCollectionView.dequeueReusableCell(
            withReuseIdentifier: TutorialCell.reuseIdentifier,
            for: indexPath) as! TutorialCell
        
        let tutorialItem: TutorialItem = viewModel.tutorialItems.value[indexPath.item]
        
        cell.configure(viewModel: TutorialCellViewModel(item: tutorialItem))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let tutorialCell = cell as? TutorialCell {
            tutorialCell.stopVideo()
        }
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
