//
//  ArticleView.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ArticleView: UIViewController {
    
    private let viewModel: ArticleViewModelType
       
    @IBOutlet weak private var articleTableView: UITableView!
    
    required init(viewModel: ArticleViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "ArticleView", bundle: nil)
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
        
        articleTableView.delegate = self
        articleTableView.dataSource = self
    }
    
    private func setupLayout() {
        
        articleTableView.register(
            UINib(nibName: ArticleCell.nibName, bundle: nil),
            forCellReuseIdentifier: ArticleCell.reuseIdentifier
        )
        articleTableView.separatorStyle = .none
        articleTableView.rowHeight = 180
    }
    
    private func setupBinding() {

        viewModel.navTitle.addObserver(self) { [weak self] (navTitle: String) in
            self?.title = navTitle
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pageViewed()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ArticleView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ArticleCell = articleTableView.dequeueReusableCell(
            withIdentifier: ArticleCell.reuseIdentifier,
            for: indexPath) as! ArticleCell
        
        return cell
    }
}
