//
//  AboutView.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AboutView: UIViewController {
    
    private let viewModel: AboutViewModelType
    
    @IBOutlet weak private var aboutTextsTableView: UITableView!
        
    required init(viewModel: AboutViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: AboutView.self), bundle: nil)
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
        
        addDefaultNavBackItem()
        
        aboutTextsTableView.delegate = self
        aboutTextsTableView.dataSource = self
    }
    
    private func setupLayout() {
        
        // aboutTextsTableView
        aboutTextsTableView.register(
            UINib(nibName: AboutTextCell.nibName, bundle: nil),
            forCellReuseIdentifier: AboutTextCell.reuseIdentifier
        )
        aboutTextsTableView.rowHeight = UITableView.automaticDimension
        aboutTextsTableView.separatorStyle = .none
    }
    
    private func setupBinding() {
        
        viewModel.navTitle.addObserver(self) { [weak self] (navTitle: String) in
            self?.title = navTitle
        }
        
        viewModel.aboutTexts.addObserver(self) { [weak self] (aboutTexts: [AboutTextModel]) in
            self?.aboutTextsTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pageViewed()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AboutView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.aboutTexts.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: AboutTextCell = aboutTextsTableView.dequeueReusableCell(
        withIdentifier: AboutTextCell.reuseIdentifier,
        for: indexPath) as! AboutTextCell
        
        let aboutTextModel: AboutTextModel = viewModel.aboutTexts.value[indexPath.row]
               
        let cellViewModel = AboutTextCellViewModel(
            aboutText: aboutTextModel
        )
        
        cell.configure(viewModel: cellViewModel)
                
        cell.selectionStyle = .none
        
        return cell
    }
}
