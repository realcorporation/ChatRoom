//
//  MessageCollectionViewFlowLayout.swift
//  ChatRoom
//
//  Created by Keith Chan on 23/4/2018.
//  Copyright © 2018 co.real. All rights reserved.
//

import UIKit

open class MessageCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        
        sectionHeadersPinToVisibleBounds = true
        minimumLineSpacing = 0
        sectionInset = .zero
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
