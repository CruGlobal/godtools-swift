//
//  FavoritedToolsView.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol FavoritedToolsViewDelegate: AnyObject {
    
    func favoritedToolsViewFindToolsTapped(favoritedToolsView: FavoritedToolsView)
}

class FavoritedToolsView: UIViewController, ToolsMenuPageView {
    
    private let viewModel: FavoritedToolsViewModelType
        
    private weak var delegate: FavoritedToolsViewDelegate?
    
    @IBOutlet weak private var openTutorialView: OpenTutorialView!
    @IBOutlet weak private var findToolsView: UIView!
    @IBOutlet weak private var searchImageView: UIImageView!
    @IBOutlet weak private var findToolsButton: UIButton!
    @IBOutlet weak private var toolsView: ToolsTableView!
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
    
    @IBOutlet weak private var openTutorialTop: NSLayoutConstraint!
    
    required init(viewModel: FavoritedToolsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: FavoritedToolsView.self), bundle: nil)
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
        
        findToolsButton.addTarget(self, action: #selector(handleFindTools(button:)), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.pageViewed()
    }
    
    func setDelegate(delegate: FavoritedToolsViewDelegate?) {
        self.delegate = delegate
    }
    
    private func setupLayout() {
        
        findToolsView.alpha = 0
        findToolsButton.layer.cornerRadius = 6
    }
    
    private func setupBinding() {
        
        toolsView.configure(viewModel: viewModel)
        
        let openTutorialViewModel = viewModel.openTutorialWillAppear()
        openTutorialView.configure(viewModel: openTutorialViewModel)
        
        openTutorialViewModel.hidesOpenTutorial.addObserver(self) { [weak self] (animatableValue: AnimatableValue<Bool>) in
            self?.setOpenTutorialHidden(animatableValue.value, animated: animatableValue.animated)
        }
        
        findToolsButton.setTitle(viewModel.findToolsTitle, for: .normal)
        
        viewModel.hidesFindToolsView.addObserver(self) { [weak self] (hidesFindToolsView: Bool) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self?.findToolsView.alpha = hidesFindToolsView ? 0 : 1
            }, completion: nil)
        }
        
        viewModel.isLoading.addObserver(self) { [weak self] (isLoading: Bool) in
            isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
        }
    }
    
    @objc func handleFindTools(button: UIButton) {
        delegate?.favoritedToolsViewFindToolsTapped(favoritedToolsView: self)
    }
    
    private func setOpenTutorialHidden(_ hidden: Bool, animated: Bool) {
        openTutorialTop.constant = hidden ? (openTutorialView.frame.size.height * -1) : 0
        
        if animated {
            if !hidden {
                openTutorialView.isHidden = false
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: { (finished: Bool) in
                    if hidden {
                        self.openTutorialView.isHidden = true
                    }
            })
        }
        else {
            openTutorialView.isHidden = hidden
            view.layoutIfNeeded()
        }
    }
    
    func pageViewed() {
        
    }
    
    func scrollToTop(animated: Bool) {
        
        toolsView.scrollToTopOfTools(animated: animated)
    }
}
