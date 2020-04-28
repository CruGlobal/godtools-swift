//
//  FindToolsView.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol AddToolsViewControllerDelegate: class {
    func moveToToolDetail(resource: DownloadedResource)
}

class FindToolsView: UIViewController {
    
    private let viewModel: FindToolsViewModelType
        
    let toolsManager = ToolsManager.shared
    
    @IBOutlet weak private var toolsTableView: UITableView!

    var emptyView = UIView()
    
    weak var delegate: AddToolsViewControllerDelegate?
    
    required init(viewModel: FindToolsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: FindToolsView.self), bundle: nil)
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
        
        self.registerCells()
        self.setupStyle()
        emptyView = addMessageForEmptyResources()
        self.view.addSubview(emptyView)
        
        setupLayout()
        setupBinding()
        
        toolsTableView.delegate = toolsManager
        toolsTableView.dataSource = toolsManager
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pageViewed()
        
        self.toolsManager.delegate = self
        self.toolsManager.loadResourceList()
        refreshView()
    }
    
    // MARK: - Helpers
    
    fileprivate func registerCells() {
        self.toolsTableView.register(
            UINib(nibName: String(describing:HomeToolTableViewCell.self), bundle: nil),
            forCellReuseIdentifier: ToolsManager.toolCellIdentifier
        )
    }
    
    fileprivate func setupStyle() {
        self.toolsTableView.separatorStyle = .none
    }
    
    func refreshView() {
        self.toolsTableView.reloadData()
        self.emptyView.isHidden = self.toolsManager.hasResources()
        self.view.setNeedsDisplay()
    }
    
    func addMessageForEmptyResources() -> UIView {
        let messageLabel = UILabel()
        let emptyBaseView = UIView()
        
        messageLabel.numberOfLines = 3
        messageLabel.font = UIFont.gtRegular(size: 16)
        messageLabel.textColor = UIColor.gtBlack
        messageLabel.layer.masksToBounds = true
        let screenSize = UIScreen.main.bounds
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        let centerX = screenSize.width/2
        let centerY = screenSize.height/2
        messageLabel.textAlignment = .center
        messageLabel.lineBreakMode = .byWordWrapping

        let labelWidth: CGFloat = 250.0
        let labelHeight: CGFloat = 90.0
        let x = (centerX - (labelWidth/2))
        let y = (centerY - (labelHeight/2))
        emptyBaseView.frame = CGRect(x: x, y: y - topBarHeight, width: labelWidth, height: labelHeight)
        messageLabel.frame = CGRect(x: 0, y: 0, width: labelWidth, height: labelHeight)
        
        messageLabel.text = "You have downloaded all available tools.".localized
        emptyBaseView.addSubview(messageLabel)
        
        return emptyBaseView
    }
}

extension FindToolsView: ToolsManagerDelegate {
    func didSelectTableViewRow(cell: HomeToolTableViewCell) {
        self.delegate?.moveToToolDetail(resource: cell.resource!)
    }
    
    func infoButtonWasPressed(resource: DownloadedResource) {
        self.delegate?.moveToToolDetail(resource: resource)
    }
    
    func downloadButtonWasPressed(resource: DownloadedResource) {
        refreshView()
    }
    
    func translationDownloadCompleted(at index: Int) {
        toolsManager.loadResourceList()
        DispatchQueue.main.async {
            self.refreshView()
        }
    }
}
