//
//  TrainingView.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TrainingView: UIViewController {
    
    private let viewModel: TrainingViewModelType
            
    @IBOutlet weak private var overlayButton: UIButton!
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var tipPagesNavigationView: PageNavigationCollectionView!
    @IBOutlet weak private var closeButton: UIButton!
    @IBOutlet weak private var progressView: ProgressView!
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var continueButton: UIButton!
    
    required init(viewModel: TrainingViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: TrainingView.self), bundle: nil)
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
        
        tipPagesNavigationView.delegate = self
        
        overlayButton.addTarget(self, action: #selector(handleOverlay(button:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(handleClose(button:)), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(handleContinue(button:)), for: .touchUpInside)
    }
    
    private func setupLayout() {
        
        tipPagesNavigationView.registerPageCell(
            nib: UINib(nibName: TrainingTipView.nibName, bundle: nil),
            cellReuseIdentifier: TrainingTipView.reuseIdentifier)
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
        
        viewModel.icon.addObserver(self) { [weak self] (icon: UIImage?) in
            self?.iconImageView.image = icon
        }
        
        viewModel.title.addObserver(self) { [weak self] (title: String) in
            self?.titleLabel.text = title
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
        viewModel.continueTapped()
    }
}

// MARK: - PageNavigationCollectionViewDelegate

extension TrainingView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        return viewModel.numberOfTipPages.value
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: TrainingTipView = pageNavigation.getReusablePageCell(
            cellReuseIdentifier: TrainingTipView.reuseIdentifier,
            indexPath: indexPath) as! TrainingTipView
        
        return cell
    }
    
    func pageNavigationDidChangePage(pageNavigation: PageNavigationCollectionView, page: Int) {
        
    }
    
    func pageNavigationDidStopOnPage(pageNavigation: PageNavigationCollectionView, page: Int) {
        
    }
}
