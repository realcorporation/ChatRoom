//
//  MessageInputBarItem.swift
//  ChatRoom
//
//  Created by Keith Chan on 23/4/2018.
//  Copyright © 2018 co.real. All rights reserved.
//

import Foundation

open class MessageInputBarItem: UIView {
    
    public enum ItemType {
        case submit
        case custom
    }
    
    open override var intrinsicContentSize: CGSize {
        return customView.intrinsicContentSize
    }
    
    var itemType: ItemType
    var customView: UIView
    
    required public init(customView: UIView, itemType: ItemType) {
        
        self.itemType = itemType
        self.customView = customView
        
        super.init(frame: .zero)
        
        customView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(customView)
        
        NSLayoutConstraint.activate([customView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     customView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     customView.topAnchor.constraint(equalTo: topAnchor),
                                     customView.bottomAnchor.constraint(equalTo: bottomAnchor)])
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
