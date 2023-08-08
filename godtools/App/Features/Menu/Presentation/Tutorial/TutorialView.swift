//
//  TutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 8/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct TutorialView: View {
    
    private let pageControlAttributes: PageControlAttributesType = GTPageControlAttributes()
    private let continueButtonHorizontalPadding: CGFloat = 50
    private let continueButtonHeight: CGFloat = 50
    
    @ObservedObject private var viewModel: TutorialViewModel
    
    init(viewModel: TutorialViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .center, spacing: 0) {
                
                FixedVerticalSpacer(height: 50)
                
                TabView(selection: $viewModel.currentPage) {
                    
                    Group {
                        
                        ForEach(0 ..< viewModel.numberOfPages, id: \.self) { index in
                            
                            TutorialItemView(
                                viewModel: viewModel.tutorialPageWillAppear(index: index),
                                geometry: geometry
                            )
                            .tag(index)
                            
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeOut, value: viewModel.currentPage)
                                                
                GTBlueButton(title: viewModel.continueTitle, font: FontLibrary.sfProTextRegular.font(size: 18), width: geometry.size.width - (continueButtonHorizontalPadding * 2), height: continueButtonHeight) {
                    
                    viewModel.continueTapped()
                }
                            
                PageControl(
                    numberOfPages: viewModel.numberOfPages,
                    attributes: pageControlAttributes,
                    currentPage: $viewModel.currentPage
                )
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
            }
            .frame(maxWidth: .infinity)
        }
    }
}


/*

import UIKit

class TutorialView: UIViewController {

    private let viewModel: TutorialViewModel
    
    private var backButton: UIBarButtonItem?
    private var closeButton: UIBarButtonItem?
    
    @IBOutlet weak private var tutorialPagesView: PageNavigationCollectionView!
    @IBOutlet weak private var continueButton: OnboardPrimaryButton!
    @IBOutlet weak private var pageControl: UIPageControl!
    
    init(viewModel: TutorialViewModel) {
        
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

    func pageNavigationDidScrollToPage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        viewModel.pageDidAppear(page: page)
    }
}
*/
