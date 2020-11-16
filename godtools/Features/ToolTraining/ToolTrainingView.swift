//
//  ToolTrainingView.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolTrainingView: UIViewController {
    
    enum ViewState {
        case visible
        case hidden
    }
    
    private let viewModel: ToolTrainingViewModelType
            
    @IBOutlet weak private var overlayButton: UIButton!
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var tipPagesNavigationView: PageNavigationCollectionView!
    @IBOutlet weak private var closeButton: UIButton!
    @IBOutlet weak private var progressView: ProgressView!
    @IBOutlet weak private var tipIconContainerView: UIView!
    @IBOutlet weak private var tipBackgroundImageView: UIImageView!
    @IBOutlet weak private var tipForegroundImageView: UIImageView!
    @IBOutlet weak private var tipTitleLabel: UILabel!
    @IBOutlet weak private var continueButton: UIButton!
    
    @IBOutlet weak private var contentViewBottom: NSLayoutConstraint!
    
    required init(viewModel: ToolTrainingViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: ToolTrainingView.self), bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
        transitioningDelegate = self
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
        
        setViewState(
            viewState: .hidden,
            animationDuration: 0,
            layoutIfNeeded: false,
            completion: nil
        )
        
        setupLayout()
        setupBinding()
        
        tipPagesNavigationView.delegate = self
        
        overlayButton.addTarget(self, action: #selector(handleOverlay(button:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(handleClose(button:)), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(handleContinue(button:)), for: .touchUpInside)
    }
    
    private func setupLayout() {
        
        view.backgroundColor = .clear
        
        overlayButton.backgroundColor = UIColor.black
        overlayButton.alpha = 0
        
        tipPagesNavigationView.registerPageCell(
            nib: UINib(nibName: ToolTrainingTipView.nibName, bundle: nil),
            cellReuseIdentifier: ToolTrainingTipView.reuseIdentifier)
        
        continueButton.layer.cornerRadius = 6
    }
    
    private func setupBinding() {
        
        viewModel.progress.addObserver(self) { [weak self] (animatableValue: AnimatableValue<CGFloat>) in
            if animatableValue.animated {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self?.progressView.progress = animatableValue.value
                }, completion: nil)
            }
            else {
                self?.progressView.progress = animatableValue.value
            }
        }
        
        viewModel.trainingTipBackgroundImage.addObserver(self) { [weak self] (backgroundImage: UIImage?) in
            self?.tipBackgroundImageView.image = backgroundImage
        }
        
        viewModel.trainingTipForegroundImage.addObserver(self) { [weak self] (foregroundImage: UIImage?) in
            self?.tipForegroundImageView.image = foregroundImage
        }
        
        viewModel.title.addObserver(self) { [weak self] (title: String) in
            self?.tipTitleLabel.text = title
        }
        
        viewModel.continueButtonTitle.addObserver(self) { [weak self] (continueButtonTitle: String) in
            self?.continueButton.setTitle(continueButtonTitle, for: .normal)
        }
        
        viewModel.numberOfTipPages.addObserver(self) { [weak self] (numberOfTipPages: Int) in
            self?.tipPagesNavigationView.reloadData()
        }
    }
    
    @objc func handleOverlay(button: UIButton) {
        viewModel.overlayTapped()
    }
    
    @objc func handleClose(button: UIButton) {
        viewModel.closeTapped()
    }
    
    @objc func handleContinue(button: UIButton) {
        tipPagesNavigationView.scrollToNextPage(animated: true)
        viewModel.continueTapped()
    }
    
    func setViewState(viewState: ViewState, animationDuration: TimeInterval, completion: ((_ finished: Bool) -> Void)?) {
        
        setViewState(
            viewState: viewState,
            animationDuration: animationDuration,
            layoutIfNeeded: true,
            completion: completion
        )
    }
    
    private func setViewState(viewState: ViewState, animationDuration: TimeInterval, layoutIfNeeded: Bool, completion: ((_ finished: Bool) -> Void)?) {
        
        let contentViewBottomConstant: CGFloat
        let overlayButtonAlpha: CGFloat
        
        switch viewState {
        
        case .visible:
            contentViewBottomConstant = 0
            overlayButtonAlpha = 0.3
            
            if layoutIfNeeded {
                view.layoutIfNeeded()
            }
        
        case .hidden:
            contentViewBottomConstant = contentView.bounds.size.height
            overlayButtonAlpha = 0
        }
        
        contentViewBottom.constant = contentViewBottomConstant
        
        if animationDuration > 0 {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
                if layoutIfNeeded {
                    self.view.layoutIfNeeded()
                }
                self.overlayButton.alpha = overlayButtonAlpha
            }) { (finished: Bool) in
                completion?(finished)
            }
        }
        else {
            if layoutIfNeeded {
                view.layoutIfNeeded()
            }
            overlayButton.alpha = 0
            completion?(true)
        }
    }
}

// MARK: - PageNavigationCollectionViewDelegate

extension ToolTrainingView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        return viewModel.numberOfTipPages.value
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ToolTrainingTipView = pageNavigation.getReusablePageCell(
            cellReuseIdentifier: ToolTrainingTipView.reuseIdentifier,
            indexPath: indexPath) as! ToolTrainingTipView

        let tipPageContentStackViewModel = viewModel.tipPageWillAppear(page: indexPath.row)
     
        cell.configure(viewModel: tipPageContentStackViewModel)
        
        return cell
    }
    
    func pageNavigationDidChangePage(pageNavigation: PageNavigationCollectionView, page: Int) {
        viewModel.tipPageDidChange(page: page)
    }
    
    func pageNavigationDidStopOnPage(pageNavigation: PageNavigationCollectionView, page: Int) {
        viewModel.tipPageDidAppear(page: page)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension ToolTrainingView: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return ToolTrainingAnimatedTransitioning(animationType: .animateIn)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return ToolTrainingAnimatedTransitioning(animationType: .animateOut)
    }
}
