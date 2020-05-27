//
//  AllToolsView.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AllToolsView: UIViewController {
    
    private let viewModel: AllToolsViewModelType
        
    @IBOutlet weak private var toolsTableView: UITableView!
    
    required init(viewModel: AllToolsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: AllToolsView.self), bundle: nil)
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
        
        toolsTableView.delegate = self
        toolsTableView.dataSource = self
    }
    
    private func setupLayout() {
        
        // TODO: Set nibName and reuseIdentifier constants in cell class. ~Levi
        toolsTableView.register(
            UINib(nibName: String(describing: HomeToolTableViewCell.self), bundle: nil),
            forCellReuseIdentifier: ToolsManager.toolCellIdentifier
        )
        toolsTableView.estimatedRowHeight = 120
        toolsTableView.rowHeight = 120
        toolsTableView.separatorStyle = .none
    }
    
    private func setupBinding() {
        
        viewModel.tools.addObserver(self) { [weak self] (tools: [DownloadedResource]) in
            self?.toolsTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pageViewed()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AllToolsView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tools.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: HomeToolTableViewCell = toolsTableView.dequeueReusableCell(
            withIdentifier: ToolsManager.toolCellIdentifier,
            for: indexPath) as! HomeToolTableViewCell
        
        return cell
    }
}
