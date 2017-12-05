//
//  EventViewController.swift
//  SEEventProject
//
//  Created by Aaron Satterfield on 11/10/17.
//  Copyright © 2017 Aaron Satterfield. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import Presentr
import SafariServices

/// Detail view controller for a specific event
class EventViewController: UIViewController {
    
    let event: Event
    var messages: [Message] = []
    
    lazy var databaseReference = Database.database().reference().child("messages").child(self.event.id)
    
    /// Text field in the bottom toolbar that a message can be entered to
    lazy var textField: UITextField = {
        let t = UITextField()
        t.borderStyle = .roundedRect
        t.textInputView.backgroundColor = UIColor.white
        t.placeholder = "Send message"
        t.delegate = self
        return t
    }()
    
    lazy var toolbarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.heightAnchor.constraint(equalToConstant: 50.0).priority = .defaultHigh
        stackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).priority = .defaultHigh
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(sendButton)
        return stackView
    }()
    
    lazy var sendButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Send", for: .normal)
        b.addTarget(self, action: #selector(self.actionDidSend), for: .touchUpInside)
        b.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        b.widthAnchor.constraint(equalToConstant: 64.0).isActive = true
        b.contentHorizontalAlignment = .right
        return b
    }()
    
    lazy var tableView: UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.delegate = self
        t.dataSource = self
        t.tableFooterView = UIView(frame: .zero)
        return t
    }()
    
    lazy var presenter: Presentr = {
        let customPresenter = Presentr(presentationType: .popup)
        customPresenter.transitionType = .coverVerticalFromTop
        customPresenter.dismissTransitionType = .crossDissolve
        customPresenter.backgroundOpacity = 0.5
        customPresenter.dismissOnSwipe = true
        customPresenter.dismissOnSwipeDirection = .top
        return customPresenter
    }()
    
    lazy var inputItem = UIBarButtonItem(customView: toolbarStackView)

    let inputToolbar = UIToolbar()
    var inputToolbarBottom = NSLayoutConstraint()
    var inputToolbarHeight = NSLayoutConstraint()

    convenience init(event: Event) {
        self.init(nibName: nil, bundle: nil, event: event)
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, event: Event) {
        self.event = event
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        title = "Chat"
        respondToKeyboard()
        view.backgroundColor = UIColor.white
        tableView.register(EventMessageTableViewCell.self, forCellReuseIdentifier: "cell")
        inputItem.width = UIScreen.main.bounds.width-32.0
        inputToolbar.setItems([inputItem], animated: false)
        view.addSubview(inputToolbar)
        view.addSubview(tableView)
        inputToolbar.translatesAutoresizingMaskIntoConstraints = false
        inputToolbarBottom = inputToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([inputToolbarBottom])
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(self.showEventInfo), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
        observeMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        inputToolbarHeight = inputToolbar.heightAnchor.constraint(equalToConstant: self.view.safeAreaInsets.bottom+50)
        NSLayoutConstraint.activate([inputToolbarHeight])
        inputToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        inputToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: inputToolbar.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    /// Get the lastes messages and continue watching for new ones to show.
    private func observeMessages() {
        let messageQuery = databaseReference.queryLimited(toLast:25)
        messageQuery.queryOrdered(byChild: "sentOn").observe(.childAdded) { (snapshot) in
            guard let item = snapshot.value else {
                return
            }
            do {
                let data = try JSONSerialization.data(withJSONObject: item, options: .prettyPrinted)
                let message = try Session.sharedSession.decoder.decode(Message.self, from: data)
                DispatchQueue.main.async {
                    self.messages.append(message)
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: IndexPath(row: self.messages.count-1, section: 0), at: .bottom, animated: true)
                }
            } catch {
                print(error)
            }
        }
    }
    
    /// Action on tap of the info icon in the top right.
    @objc
    func showEventInfo() {
        customPresentViewController(presenter, viewController: EventInfoViewController(event: event, delegate: self), animated: true, completion: nil)
    }

    /// Creates message and sends it to the event conversation
    @objc
    func actionDidSend() {
        guard let user = Session.sharedSession.currentUser else {
            log.error("User is not logged in")
            return
        }
        guard let text = textField.text, !text.isEmpty else {
            return
        }
        textField.text = ""
        let message = Message(id: UUID(), messageSender: user, body: text, sentOn: Date())
        Session.sharedSession.send(message: message, for: event.id) { (success) in
            
        }
    }
    
    /// Listens to the keyboard notification to animate the text field at the bottom to stay above the keyboard
    override func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.keyboardEndFrame() else {
            return
        }

        inputToolbarBottom.constant = -keyboardFrame.height
        inputToolbarHeight.constant = 50.0
        view.setNeedsLayout()
        UIView.animate(withDuration: notification.keyboardAnimationDuration() ?? 0.25, animations: {
            self.view.layoutIfNeeded()
        }) { (done) in
            guard done else {return}
            guard self.messages.count > 0 else { return }
            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count-1, section: 0), at: .bottom, animated: true)
        }
    }
    
    /// Listens to the keyboard notification to animate the text field at the bottom to stay above the keyboard
    override func keyboardWillHide(notification: Notification) {
        inputToolbarBottom.constant = 0.0
        inputToolbarHeight.constant = self.view.safeAreaInsets.bottom+50
        view.setNeedsLayout()
        UIView.animate(withDuration: notification.keyboardAnimationDuration() ?? 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
}

extension EventViewController: EventInfoControllerDelegate {
    
    func didSelectLink(url: URL) {
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
}

extension EventViewController: UITextFieldDelegate {
    
}

extension EventViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return EventMessageTableViewCell.cellHeight(with: messages[indexPath.row].body)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? EventMessageTableViewCell else {
            fatalError("Did not register EventMessageTableViewCell")
        }
        cell.set(message: messages[indexPath.row] )
        return cell
    }
    
}
