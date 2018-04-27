//
//  ChatRoomViewController.swift
//  Example
//
//  Created by Keith Chan on 24/4/2018.
//  Copyright © 2018 co.real. All rights reserved.
//

import ChatRoom

class CustomButtonView: UIStackView {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 44, height: 44)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class AddButton: UIButton {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 44, height: 44)
    }
}

class SendButton: UIButton {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width + 16, height: 44)
    }
}

final class ChatRoomViewController: MessageViewController {
    
    var messageLists = [String]()
    
    let sendButton: SendButton = {
        let button = SendButton(type: .custom)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .highlighted)
        return button
    }()
    
    let addButton: AddButton = {
        let button = AddButton(type: .custom)
        button.setTitle("Add", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .highlighted)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // messageLists = ["Hello1", "Hello2", "Hello3", "Hello4", "Hello5", "Hello6", "Hello7", "Hello8", "Hello9", "Hello10"]
        
        delegate = self
        
        sendButton.addTarget(self, action: #selector(send(_:)), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        messageLists = []
        // messageLists = ["Hello1", "Hello2", "Hello3", "Hello4", "Hello5", "Hello6", "Hello7", "Hello8", "Hello9", "Hello10"]
        var data = [String]()
        for i in 0..<10000 {
            let string = "Hello" + String(i)
            data.append(string)
        }
        
        DispatchQueue.main.async {
            self.messageLists = data
            self.reloadData(shouldScrollToBottom: true, animated: false)
        }
        
    }
    
    override func configureCollectionView(_ collectionView: MessageCollectionView, layout: MessageCollectionViewFlowLayout) {
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func configureInputBar(_ inputBar: MessageInputBar) {
        
        inputBar.barItemsSpacing = 4
        inputBar.backgroundColor = UIColor.lightGray
        inputBar.growingTextView.textView.backgroundColor = .white
        inputBar.growingTextView.placeholderAttributedText = NSAttributedString(string: "Message", attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .body),
                                                                                                                NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        inputBar.topHairLineHeight = 0.5
        inputBar.topHairline.backgroundColor = UIColor.brown
        
        let addItem = MessageInputBarItem(customView: addButton, itemType: .custom)
        inputBar.setLeadingItems([addItem], for: .normal)
        
        let sendItem = MessageInputBarItem(customView: sendButton, itemType: .submit)
        inputBar.setTrailingItems([sendItem], for: .textEditing)
    }
    
    @objc func send(_ sender: SendButton) {
        submitInput()
    }
}

extension ChatRoomViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MessageCell
        cell.backgroundColor = .white
        cell.textView.text = messageLists[indexPath.row]
        return cell
    }
}

extension ChatRoomViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 73)
    }
}

extension ChatRoomViewController: MessageViewControllerDelegate {
    
    func messageViewController(_ controller: MessageViewController, textWillSubmit text: String) {
        messageLists.append(text)
        
        reloadData(shouldScrollToBottom: true, animated: true)
        
//        let indexPath = IndexPath(item: messageLists.count - 1, section: 0)
//        messageCollectionView.performBatchUpdates({ [weak self] in
//            self?.messageCollectionView.insertItems(at: [indexPath])
//        }) { [weak self] (_) in
//            self?.scrollToBottom(animated: true)
//        }
    }
    
    func messageViewController(_ controller: MessageViewController, textDidClear text: String) {
        
    }
    
    func messageViewController(_ controller: MessageViewController, imagesDidPaste images: [UIImage]) {
        
    }
    
    func messageViewController(_ controller: MessageViewController, typingStateDidChange typingState: MessageViewController.TypingState) {
        switch typingState {
        case .idle:
            print("idle")
            title = ""
            break
        case .typing:
            print("you are typing...")
            title = "you are typing..."
            break
        }
    }
}
