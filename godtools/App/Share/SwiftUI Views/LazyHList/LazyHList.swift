//
//  LazyHList.swift
//  godtools
//
//  Created by Levi Eggert on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI
import UIKit

struct LazyHList<Content: View>: UIViewRepresentable {

    let cellIdentifier: String = "lazyHListCustomCell"
    let itemSize: CGSize
    let itemSpacing: CGFloat
    let contentInsets: EdgeInsets
    let showsScrollIndicator: Bool
    
    @Binding var numberOfItems: Int
    
    let viewForItem: ((_ index: Int) -> Content)
    let itemTapped: ((_ index: Int) -> Void)
    
    func makeCoordinator() -> LazyHListCoordinator<Content> {
        return LazyHListCoordinator(lazyHList: self)
    }
    
    func makeUIView(context: Context) -> UICollectionView {
        
        let horizontalLayout = UICollectionViewFlowLayout()
        horizontalLayout.scrollDirection = .horizontal
        
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: itemSize.height)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: horizontalLayout)
        
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: contentInsets.top, left: contentInsets.leading, bottom: contentInsets.bottom, right: contentInsets.trailing)
        collectionView.showsVerticalScrollIndicator = showsScrollIndicator
        collectionView.showsHorizontalScrollIndicator = showsScrollIndicator
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.delegate = context.coordinator
        collectionView.dataSource = context.coordinator
        
        return collectionView
    }
    
    func updateUIView(_ collectionView: UICollectionView, context: Context) {
        
        collectionView.reloadData()
    }
}
