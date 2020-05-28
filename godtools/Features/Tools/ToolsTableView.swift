//
//  ToolsTableView.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolsTableView: UIView, NibBased {
    
    private var viewModel: ToolsViewModelType?
    
    @IBOutlet weak private var tableView: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        loadNib()
                
        setupLayout()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configure(viewModel: ToolsViewModelType) {
        
        self.viewModel = viewModel
        
        setupBinding()
    }
    
    private func setupLayout() {
        
        tableView.register(
            UINib(nibName: ToolCell.nibName, bundle: nil),
            forCellReuseIdentifier: ToolCell.reuseIdentifier
        )
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
    }
    
    private func setupBinding() {
        
        viewModel?.tools.addObserver(self) { [weak self] (tools: [DownloadedResource]) in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ToolsTableView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.tools.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ToolCell = tableView.dequeueReusableCell(
            withIdentifier: ToolCell.reuseIdentifier,
            for: indexPath) as! ToolCell
        
        cell.selectionStyle = .none
                
        return cell
    }
}
