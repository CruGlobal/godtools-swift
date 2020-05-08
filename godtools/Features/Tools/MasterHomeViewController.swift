//
//  MasterHomeViewController.swift
//  godtools
//
//  Created by Greg Weiss on 4/2/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit
import PromiseKit

class MasterHomeViewController: UIViewController  {
        
    private var segmentedControl = UISegmentedControl()
    
    private let viewModel: MasterHomeViewModelType
    private let toolsManager = ToolsManager.shared
            
    private lazy var homeViewController: HomeViewController = {
        
        let myToolsViewModel = MyToolsViewModel(flowDelegate: viewModel.flowDelegate!, analytics: viewModel.analytics)
        let view = HomeViewController(viewModel: myToolsViewModel)
        
        view.findDelegate = self
        
        // Add View Controller as Child View Controller
        add(asChildViewController: view)
        
        return view
    }()
    
    private lazy var addToolsViewController: FindToolsView = {
        
        let findToolsViewModel = FindToolsViewModel(flowDelegate: viewModel.flowDelegate!, analytics: viewModel.analytics)
        let view = FindToolsView(viewModel: findToolsViewModel)
                
        // TODO: I think view might get added twice because this is called from segment. ~Levi
        add(asChildViewController: view)
        
        return view
    }()
    
    @IBOutlet weak private var openTutorialView: OpenTutorialView!
    @IBOutlet weak private var containmentView: UIView!
    
    @IBOutlet weak private var openTutorialTop: NSLayoutConstraint!
    @IBOutlet weak private var openTutorialHeight: NSLayoutConstraint!

    required init(viewModel: MasterHomeViewModelType) {
        self.viewModel = viewModel
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
        
        addAccessibilityIdentifiers()
        
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
    
    private func determineMyToolsSegment() -> String {
        let myTools = "my_tools".localized
        return myTools
    }
    
    private func determineFindToolsSegment() -> String {
        let findTools = "find_tools".localized
        return findTools
    }
    
    private func determineSegmentFontSize(myTools: String, findTools: String) -> CGFloat {
        let count = (myTools.count > findTools.count) ? myTools.count : findTools.count
        var fontSize: CGFloat = 15.0
        if count > 14 {
            switch count {
            case 15:
                fontSize = 14.0
            case 16:
                fontSize = 13.5
            case 17:
                fontSize = 13.0
            case 18:
                fontSize = 12.5
            default:
                fontSize = 12.0
            }
        }
        
        return fontSize
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
    
    func addAccessibilityIdentifiers() {
        segmentedControl.accessibilityIdentifier = GTAccessibilityConstants.Home.homeNavSegmentedControl
    }

}

extension MasterHomeViewController: FindToolsDelegate {
    
    func goToFindTools() {
        segmentedControl.selectedSegmentIndex = 1
        updateView()
    }

}
