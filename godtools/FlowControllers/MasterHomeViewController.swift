//
//  MasterHomeViewController.swift
//  godtools
//
//  Created by Greg Weiss on 4/2/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit
import PromiseKit

protocol MasterHomeViewControllerDelegate {
    mutating func moveToUpdateLanguageSettings()
    mutating func moveToToolDetail(resource: DownloadedResource)
    mutating func moveToTract(resource: DownloadedResource)
}

class MasterHomeViewController: BaseViewController  {
    
    var segmentedControl = UISegmentedControl()
    
    let toolsManager = ToolsManager.shared
    
    var delegate: MasterHomeViewControllerDelegate?
    
    private lazy var homeViewController: HomeViewController = {
        
        let viewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
        viewController.delegate = self
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var addToolsViewController: AddToolsViewController = {
        
        let viewController = AddToolsViewController(nibName: "AddToolsViewController", bundle: nil)
        viewController.delegate = self
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.defineObservers()
        toolsManager.delegate = self
        navigationController?.navigationBar.barStyle = .black
        setupView()
    }
    
    func addMyToolsFindToolsControl() {
        
        let myTools = determineMyToolsSegment()
        let findTools = determineFindToolsSegment()
        let fontSize = determineSegmentFontSize(myTools: myTools, findTools: findTools)
        let font = UIFont.systemFont(ofSize: fontSize)

        segmentedControl = UISegmentedControl(items: [myTools, findTools])
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        segmentedControl.sizeToFit()
    }
    
    // MARK: - View Methods
    
    private func setupView() {
        setupSegmentedControl()
        updateView()
    }
    
    private func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            remove(asChildViewController: addToolsViewController)
            add(asChildViewController: homeViewController)
        } else {
            remove(asChildViewController: homeViewController)
            add(asChildViewController: addToolsViewController)
        }
    }
    
    private func setupSegmentedControl() {
        // Configure Segmented Control
        
        segmentedControl.removeAllSegments()
        addMyToolsFindToolsControl()
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        
        // Select First Segment
        segmentedControl.selectedSegmentIndex = 0
        
        self.navigationItem.titleView = segmentedControl
    }
    
    // MARK: - Actions
    
    func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }
    
    override func homeButtonAction() {
        self.baseDelegate?.goHome()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func navigationLanguageButtonAction() {
        self.delegate?.moveToUpdateLanguageSettings()
    }

    // MARK: - Helper Methods
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
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
        self.addNavigationBurgerButton()
        self.addNavigationLanguageButton()
    }
    
    // MARK: - Analytics
    
    override func screenName() -> String {
        return "Home"
    }

}

extension MasterHomeViewController: LanguageSettingsViewControllerDelegate {
    
    func moveToLanguagesList(primaryLanguage: Bool) {
        let viewController = LanguagesTableViewController(nibName: String(describing:LanguagesTableViewController.self), bundle: nil)
        viewController.delegate = self
        viewController.selectingForPrimary = primaryLanguage
        // self.pushViewController(viewController: viewController)
        self.navigationController?.pushViewController(viewController, animated: true)
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
}

extension MasterHomeViewController: ToolsManagerDelegate, LanguagesTableViewControllerDelegate {

    func infoButtonWasPressed(resource: DownloadedResource) {
        // Tools Manager Delegate required
    }
    
}
