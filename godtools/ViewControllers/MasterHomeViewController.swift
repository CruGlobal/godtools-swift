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
    func moveToUpdateLanguageSettings()
    func moveToToolDetail(resource: DownloadedResource)
    func moveToTract(resource: DownloadedResource)
    func moveToArticle(resource: DownloadedResource)
}

class MasterHomeViewController: BaseViewController  {
        
    private var segmentedControl = UISegmentedControl()
    
    private let tutorialServices: TutorialServicesType
    private let toolsManager = ToolsManager.shared
        
    private weak var flowDelegate: FlowDelegate?
    private weak var delegate: MasterHomeViewControllerDelegate?
    
    private lazy var homeViewController: HomeViewController = {
        
        let viewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
        viewController.delegate = self
        viewController.findDelegate = self
        
        // Add View Controller as Child View Controller
        add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var addToolsViewController: AddToolsViewController = {
        
        let viewController = AddToolsViewController(nibName: "AddToolsViewController", bundle: nil)
        viewController.delegate = self
        
        // Add View Controller as Child View Controller
        add(asChildViewController: viewController)
        
        return viewController
    }()
    
    @IBOutlet weak private var openTutorialView: OpenTutorialView!
    @IBOutlet weak private var containmentView: UIView!
    
    @IBOutlet weak private var openTutorialTop: NSLayoutConstraint!
    @IBOutlet weak private var openTutorialHeight: NSLayoutConstraint!

    required init(flowDelegate: FlowDelegate, delegate: MasterHomeViewControllerDelegate, tutorialServices: TutorialServicesType) {
        self.flowDelegate = flowDelegate
        self.delegate = delegate
        self.tutorialServices = tutorialServices
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
        
        setupBinding()
        
        defineObservers()
        toolsManager.delegate = self
        navigationController?.navigationBar.barStyle = .black
        setupView()
    }

    private func setupBinding() {
        
        let openTutorialViewModel = OpenTutorialViewModel(
            flowDelegate: self,
            tutorialServices: tutorialServices
        )
        openTutorialView.configure(viewModel: openTutorialViewModel)
        openTutorialViewModel.hidesOpenTutorial.addObserver(self) { [weak self] (tuple: (hidden: Bool, animated: Bool)) in
            self?.setOpenTutorialHidden(tuple.hidden, animated: tuple.animated)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func addMyToolsFindToolsControl() {
        
        let myTools = determineMyToolsSegment()
        let findTools = determineFindToolsSegment()
        let fontSize = determineSegmentFontSize(myTools: myTools, findTools: findTools)
        let font = UIFont.systemFont(ofSize: fontSize)
        
        let myToolsTitle: NSString = NSString(string: determineMyToolsSegment())
        myToolsTitle.accessibilityLabel = "my_tools"
        let findToolsTitle: NSString = NSString(string: determineFindToolsSegment())
        findToolsTitle.accessibilityLabel = "find_tools"

        segmentedControl = UISegmentedControl(items: [myToolsTitle, findToolsTitle])
        
        if #available(iOS 13.0, *) {
            segmentedControl.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.white], for: .normal)
            segmentedControl.setTitleTextAttributes([.font: font, .foregroundColor: UIColor(red: 0 / 255, green: 173 / 255, blue: 218 / 255, alpha: 1)], for: .selected)
            segmentedControl.layer.borderColor = UIColor.white.cgColor
            segmentedControl.layer.borderWidth = 1
        }
        else {
            // Fallback on earlier versions
            segmentedControl.setTitleTextAttributes([.font: font], for: .normal)
        }
        
        segmentedControl.sizeToFit()
    }
    
    // MARK: - View Methods
    
    private func setupView() {
        setupSegmentedControl()
        updateView()
    }
    
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
    
    private func setupSegmentedControl() {
        // Configure Segmented Control
        
        segmentedControl.removeAllSegments()
        addMyToolsFindToolsControl()
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        
        // Select First Segment
        segmentedControl.selectedSegmentIndex = 0
        
        navigationItem.titleView = segmentedControl
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
    
    override func navigationLanguageButtonAction() {
        delegate?.moveToUpdateLanguageSettings()
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
    
    // MARK: - Navigation Buttons
    
    override func configureNavigationButtons() {
        addNavigationBurgerButton()
        addNavigationLanguageButton()
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

extension MasterHomeViewController: LanguageSettingsViewControllerDelegate {
    
    func moveToLanguagesList(primaryLanguage: Bool) {
        let viewController = LanguagesTableViewController(nibName: String(describing:LanguagesTableViewController.self), bundle: nil)
        viewController.delegate = self
        viewController.selectingForPrimary = primaryLanguage
        // pushViewController(viewController: viewController)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension MasterHomeViewController: HomeViewControllerDelegate, AddToolsViewControllerDelegate {
    
    func moveToUpdateLanguageSettings() {
        delegate?.moveToUpdateLanguageSettings()
    }
    
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

extension MasterHomeViewController: ToolsManagerDelegate, LanguagesTableViewControllerDelegate {

    func infoButtonWasPressed(resource: DownloadedResource) {
        // Tools Manager Delegate required
    }
    
}

// MARK: - FlowDelegate

extension MasterHomeViewController: FlowDelegate {
    func navigate(step: FlowStep) {
        flowDelegate?.navigate(step: step)
    }
}
