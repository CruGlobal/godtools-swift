//
//  MasterHomeViewController.swift
//  godtools
//
//  Created by Greg Weiss on 4/2/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit
import PromiseKit

protocol MasterHomeViewControllerDelegate: class {
    func moveToToolDetail(resource: DownloadedResource)
    func moveToTract(resource: DownloadedResource)
    func moveToArticle(resource: DownloadedResource)
}

class MasterHomeViewController: BaseViewController  {
        
    private var segmentedControl = UISegmentedControl()
    
    private let viewModel: MasterHomeViewModelType
    private let toolsManager = ToolsManager.shared
        
    private weak var delegate: MasterHomeViewControllerDelegate?
    
    private lazy var homeViewController: HomeViewController = {
        
        let viewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
        viewController.delegate = self
        viewController.findDelegate = self
        
        // Add View Controller as Child View Controller
        add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var addToolsViewController: FindToolsView = {
        
        let findToolsViewModel = FindToolsViewModel(analytics: self.viewModel.analytics)
        let view = FindToolsView(viewModel: findToolsViewModel)
        
        // TODO: Would like to remove delegate and use flow ~Levi.
        view.delegate = self
        
        // TODO: I think view might get added twice because this is called from segment. ~Levi
        add(asChildViewController: view)
        
        return view
    }()
    
    @IBOutlet weak private var openTutorialView: OpenTutorialView!
    @IBOutlet weak private var containmentView: UIView!
    
    @IBOutlet weak private var openTutorialTop: NSLayoutConstraint!
    @IBOutlet weak private var openTutorialHeight: NSLayoutConstraint!

    required init(viewModel: MasterHomeViewModelType, delegate: MasterHomeViewControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: "MasterHomeViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupBinding()
        
        defineObservers()
                
        segmentedControl.addTarget(
            self,
            action: #selector(selectionDidChange(_:)), for: .valueChanged
        )
        segmentedControl.selectedSegmentIndex = 0
        
        updateView()
        
        _ = addBarButtonItem(
            to: .left,
            image: ImageCatalog.navMenu.image,
            color: .white,
            target: self,
            action: #selector(handleMenu(barButtonItem:))
        )
        
        _ = addBarButtonItem(
            to: .right,
            image: ImageCatalog.navLanguage.image,
            color: .white,
            target: self,
            action: #selector(handleLanguage(barButtonItem:))
        )
    }
    
    private func setupLayout() {
        
        navigationController?.navigationBar.barStyle = .black
        
        navigationItem.titleView = segmentedControl
        
        // segemnted control
        let myTools = determineMyToolsSegment()
        let findTools = determineFindToolsSegment()
        let fontSize = determineSegmentFontSize(myTools: myTools, findTools: findTools)
        let font = UIFont.defaultFont(size: fontSize, weight: nil)
        
        let myToolsTitle: NSString = NSString(string: determineMyToolsSegment())
        myToolsTitle.accessibilityLabel = "my_tools"
        let findToolsTitle: NSString = NSString(string: determineFindToolsSegment())
        findToolsTitle.accessibilityLabel = "find_tools"

        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: String(myToolsTitle), at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: String(findToolsTitle), at: 1, animated: false)
        
        if #available(iOS 13.0, *) {
            segmentedControl.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.white], for: .normal)
            segmentedControl.setTitleTextAttributes([.font: font, .foregroundColor: UIColor(red: 0 / 255, green: 173 / 255, blue: 218 / 255, alpha: 1)], for: .selected)
            segmentedControl.layer.borderColor = UIColor.white.cgColor
            segmentedControl.layer.borderWidth = 1
            segmentedControl.selectedSegmentTintColor = .white
            segmentedControl.backgroundColor = .clear
        }
        else {
            // Fallback on earlier versions
            segmentedControl.setTitleTextAttributes([.font: font], for: .normal)
        }
        
        segmentedControl.sizeToFit()
    }

    private func setupBinding() {
        
        if let flowDelegate = viewModel.flowDelegate {
         
            let openTutorialViewModel = OpenTutorialViewModel(
                flowDelegate: flowDelegate,
                tutorialAvailability: viewModel.tutorialAvailability,
                openTutorialCalloutCache: viewModel.openTutorialCalloutCache,
                analytics: viewModel.analytics
            )
            openTutorialView.configure(viewModel: openTutorialViewModel)
            openTutorialViewModel.hidesOpenTutorial.addObserver(self) { [weak self] (tuple: (hidden: Bool, animated: Bool)) in
                self?.setOpenTutorialHidden(tuple.hidden, animated: tuple.animated)
            }
        }
    }
    
    @objc func handleMenu(barButtonItem: UIBarButtonItem) {
        viewModel.menuTapped()
    }
    
    @objc func handleLanguage(barButtonItem: UIBarButtonItem) {
        viewModel.languageTapped()
    }
    
    // MARK: - View Methods
    
    func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            remove(asChildViewController: addToolsViewController)
            add(asChildViewController: homeViewController)
        } else {
            remove(asChildViewController: homeViewController)
            add(asChildViewController: addToolsViewController)
            UserDefaults.standard.set(true, forKey: GTConstants.kHasTappedFindTools)
        }
    }
    
    private func setOpenTutorialHidden(_ hidden: Bool, animated: Bool) {
        openTutorialTop.constant = hidden ? (openTutorialHeight.constant * -1) : 0
        
        if animated {
            if !hidden {
                openTutorialView.isHidden = false
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.view.layoutIfNeeded()
                }, completion: { [weak self] (finished: Bool) in
                    if hidden {
                        self?.openTutorialView.isHidden = true
                    }
            })
        }
        else {
            openTutorialView.isHidden = hidden
            view.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    
    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }
    
    override func homeButtonAction() {
        baseDelegate?.goHome()
        navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - Helper Methods
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        containmentView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = containmentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParent()
    }
    
    // Notifications
    
    func defineObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadView),
                                               name: .downloadPrimaryTranslationCompleteNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadView),
                                               name: .reloadHomeListNotification,
                                               object: nil)
    }
    
    @objc private func reloadView() {
        toolsManager.loadResourceList()
    }
    
    // MARK: - Analytics
    
    override func screenName() -> String {
        return "Home"
    }
    
    // MARK: - Accessiblity
    
    override func addAccessibilityIdentifiers() {
        segmentedControl.accessibilityIdentifier = GTAccessibilityConstants.Home.homeNavSegmentedControl
    }

}

extension MasterHomeViewController: HomeViewControllerDelegate, AddToolsViewControllerDelegate {
    
    func moveToToolDetail(resource: DownloadedResource) {
        delegate?.moveToToolDetail(resource: resource)
    }
    
    func moveToTract(resource: DownloadedResource) {
        delegate?.moveToTract(resource: resource)
    }
    func moveToArticle(resource: DownloadedResource) {
        delegate?.moveToArticle(resource: resource)
    }
    
}

extension MasterHomeViewController: FindToolsDelegate {
    
    func goToFindTools() {
        segmentedControl.selectedSegmentIndex = 1
        updateView()
    }

}
