//
//  MessageInputBar.swift
//  ChatRoom
//
//  Created by Keith Chan on 23/4/2018.
//  Copyright © 2018 co.real. All rights reserved.
//

import UIKit
import NextGrowingTextView

protocol MessageInputBarDelegate: NSObjectProtocol {
    func messageInputBar(_ inputBar: MessageInputBar, willChangeHeight height: CGFloat)
    func messageInputBar(_ inputBar: MessageInputBar, didChangeHeight height: CGFloat)
    
    func messageInputBar(_ inputBar: MessageInputBar, textDidChange text: String)
}

open class MessageInputBar: UIView {
    
    public enum State {
        case normal
        case typing
    }
    
    class BarItems {
        var state: State
        var leadingItems = [MessageInputBarItem]()
        var trailingItems = [MessageInputBarItem]()
        
        required init(state: State) {
            self.state = state
        }
    }
    
    open private(set) var state: MessageInputBar.State = .normal {
        didSet {
            guard oldValue != state else { return }
            changeState(state)
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        let margins = layoutMargins
        return CGSize(width: super.intrinsicContentSize.width, height: max(44.0, growingTextView.intrinsicContentSize.height + margins.top + margins.bottom))
    }
    
    override open class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    weak var delegate: MessageInputBarDelegate?
    
    private(set) var growingTextView: NextGrowingTextView = {
        let growingTextView = NextGrowingTextView(frame: .zero)
        growingTextView.minNumberOfLines = 1
        growingTextView.maxNumberOfLines = 5
        growingTextView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        growingTextView.textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        growingTextView.layer.cornerRadius = 8
        growingTextView.layer.masksToBounds = true
        growingTextView.textView.font = UIFont.preferredFont(forTextStyle: .body)
        return growingTextView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    open private(set) var topHairline: UIView = {
        let topHairline = UIView()
        topHairline.backgroundColor = .lightGray
        return topHairline
    }()
    
    open var topHairLineHeight = CGFloat(1)
    
    private var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundView
    }()
    
    private var normalStateBarItems = BarItems(state: .normal)
    private var typingStateBarItems = BarItems(state: .typing)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        initViews()
        setupDelegates()
    }
    
    private func initViews() {
        
        layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        backgroundColor = .white
        
        stackView.addArrangedSubview(growingTextView)
        
        addSubview(backgroundView)
        addSubview(stackView)
        
        NSLayoutConstraint.activate([backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     backgroundView.topAnchor.constraint(equalTo: topAnchor),
                                     backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 34)])
        
        let guide = layoutMarginsGuide
        NSLayoutConstraint.activate([stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
                                     stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
                                     stackView.topAnchor.constraint(equalTo: guide.topAnchor),
                                     stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)])
        
        addSubview(topHairline)
    }
    
    private func setupDelegates() {
        growingTextView.delegates.willChangeHeight = { [weak self] height in
            guard let strongSelf = self else { return }
            
            strongSelf.delegate?.messageInputBar(strongSelf, willChangeHeight: height)
        }
        
        growingTextView.delegates.didChangeHeight = { [weak self] height in

            guard let strongSelf = self else { return }

            let margins = strongSelf.layoutMargins
            let adjustedHeight = max(44.0, height + margins.top + margins.bottom)
            
            guard strongSelf.frame.height != adjustedHeight else { return }
            
            strongSelf.delegate?.messageInputBar(strongSelf, didChangeHeight: adjustedHeight)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChangeNotification(_:)), name: NSNotification.Name.UITextViewTextDidChange, object: growingTextView.textView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        topHairline.frame = CGRect(x: 0, y: 0, width: frame.width, height: topHairLineHeight)
    }
    
    open func setLeadingItems(_ leadingItems: [MessageInputBarItem], for state: MessageInputBar.State) {
        switch state {
        case .normal:
            normalStateBarItems.leadingItems = leadingItems
            break
        case .typing:
            typingStateBarItems.leadingItems = leadingItems
            break
        }
        
        configureStackView()
    }
    
    open func setTrailingItems(_ trailingItems: [MessageInputBarItem], for state: MessageInputBar.State) {
        switch state {
        case .normal:
            normalStateBarItems.trailingItems = trailingItems
            break
        case .typing:
            typingStateBarItems.trailingItems = trailingItems
            break
        }
        
        configureStackView()
    }
    
    // MARK: - Private Methods
    
    private func configureStackView() {
        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0) }
        
        for item in normalStateBarItems.leadingItems {
            item.isHidden = normalStateBarItems.state != state
            stackView.addArrangedSubview(item)
        }
        
        for item in typingStateBarItems.leadingItems {
            item.isHidden = typingStateBarItems.state != state
            stackView.addArrangedSubview(item)
        }
        
        stackView.addArrangedSubview(growingTextView)
        
        for item in normalStateBarItems.trailingItems {
            item.isHidden = normalStateBarItems.state != state
            stackView.addArrangedSubview(item)
        }
        
        for item in typingStateBarItems.trailingItems {
            item.isHidden = typingStateBarItems.state != state
            stackView.addArrangedSubview(item)
        }
    }
    
    private func changeState(_ state: State) {
        switch state {
        case .normal:
            normalStateBarItems.leadingItems.forEach { $0.isHidden = false }
            normalStateBarItems.trailingItems.forEach { $0.isHidden = false }
            typingStateBarItems.leadingItems.forEach { $0.isHidden = true }
            typingStateBarItems.trailingItems.forEach { $0.isHidden = true }
            break
        case .typing:
            if typingStateBarItems.leadingItems.count == 0 {
                normalStateBarItems.leadingItems.forEach { $0.isHidden = false }
            } else {
                normalStateBarItems.leadingItems.forEach { $0.isHidden = true }
                typingStateBarItems.leadingItems.forEach { $0.isHidden = false }
            }
            
            if typingStateBarItems.trailingItems.count == 0 {
                normalStateBarItems.trailingItems.forEach { $0.isHidden = false }
            } else {
                normalStateBarItems.trailingItems.forEach { $0.isHidden = true }
                typingStateBarItems.trailingItems.forEach { $0.isHidden = false }
            }
            break
        }
    }
    
    func resetState() {
        state = .normal
    }
    
    // MARK: - Notifications
    
    @objc private func textDidChangeNotification(_ noti: Notification) {
        guard let textView = noti.object as? UITextView else { return }
        
        if let text = textView.text, text.count > 0 {
            state = .typing
        } else {
            state = .normal
        }
        
        delegate?.messageInputBar(self, textDidChange: textView.text ?? "")
    }
}

