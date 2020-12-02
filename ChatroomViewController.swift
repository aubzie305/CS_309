//
//  ChatroomViewController.swift
//  Zentopia
//
//  Created by Riley Millam on 9/19/20.
//  Copyright © 2020 Aubrey Uriel Sijo-Gonzalez. All rights reserved.
//

import Foundation
import UIKit

class ChatroomViewController: ChatController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var chatLog: UITableView!
    @IBOutlet weak var chatBox: UITextField!
    
    var viewIsSet: Bool?
    var ChatID: UInt = 0
    var chatMessages = [ChatMessage]()
    let formatter: DateFormatter = DateFormatter()
    var date: String?
    
    var urlSession = URLSession(configuration: .default)
    var webSocketTask: URLSessionWebSocketTask!
        
    override func viewDidLoad() {
        super.viewDidLoad(chatLog, chatBox)
        viewIsSet = self.setUpViewController()
        chatLog.delegate = self
        chatLog.dataSource = self
        chatLog.separatorStyle = .none
        formatter.dateFormat = "hh:mm:ss MM-dd-yyyy"
        date = formatter.string(for: Date())
    
        let backButton = ExitChatroomButton(color: UIColor(.RED), text: "Back", width: width - 32, height: 24)
        backButton.moveRect(newX: xCenter, newY: 48)
        self.view.addSubview(backButton)
        
        self.chatBox.autocorrectionType = .no
    
        //Watches for keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    
        switch  ChatID {
            case 1:
                self.view.backgroundColor = UIColor(.PINK)
            case 2:
                self.view.backgroundColor = UIColor(.GREEN)
            case 3:
                self.view.backgroundColor = UIColor(.ORANGE)
            case 4:
                self.view.backgroundColor = UIColor(.YELLOW)
            case 5:
                self.view.backgroundColor = UIColor(.BLUE)
            case 6:
                self.view.backgroundColor = UIColor(.PURPLE)
            default: print("ChatID wasn't passed though segue")
        }
        
        presenter?.onViewLoadedCVCP()
        
        // Open websocket connection upon view load
        let url = URL(string: "ws://coms-309-kk-05.cs.iastate.edu/chatroom?id=\(ChatID)&userName=\(Constants.currentUser)")
        self.webSocketTask = self.urlSession.webSocketTask(with: url!)
        self.getMessages()
        self.webSocketTask.resume()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        let message = URLSessionWebSocketTask.Message.string(self.chatbox!.text!)
        self.webSocketTask.send(message) { error in
            if let error = error {
                print("Websocket sending error: \(error)")
            } else {
                print("Sent")
            }
        }

        self.chatBox.text = ""
        
        return true
    }
    
    func getMessages() {
        self.webSocketTask.receive{ result in
            switch result {
            case .failure(let error):
                print("Failed to receive messages \(error)")
                
            case .success(let messages):
                switch messages {
                case .string(let text):
                    print("Received message: \(text)")

                    switch text {
                    case "Message is too long!":
                        DispatchQueue.main.async {
                            self.displayAlert()
                        }
                    default:
                        let msgArrays = try? JSONDecoder().decode([ChatMessage].self, from: text.data(using: .utf8)!)
                        let msg = try? JSONDecoder().decode(ChatMessage.self, from: text.data(using: .utf8)!)
                        
                        DispatchQueue.main.async {
                            if(msgArrays != nil) {
                                self.chatMessages = msgArrays!
                            } else if(msg != nil && msg?.chatroomID == Int(self.ChatID)){
                                self.chatMessages.append(msg!)
                            } else {
                                print("Unable to parse JSON requests")
                            }
                            
                            if(self.chatMessages.count > 0) {
                                self.chatLog.reloadData()
                                print("Loaded 1 new message into chat")
                                self.chatLog.scrollToRow(at: IndexPath(row: self.chatMessages.count - 1, section: 0), at: .bottom, animated: true)
                            }
                        }
                    }
                    
                case .data(let data):
                    print("Received data: \(data)")
                    
                @unknown default:
                    fatalError()
                }
            }
            
            self.getMessages()
        }
    }
    
    func displayAlert() {
        let alertView = UIAlertController(title: "Message too long", message: "Please limit message to 150 words", preferredStyle: .alert)

        let confirmViewHeight = NSLayoutConstraint(item: alertView.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 150)
        let confirmViewWidth = NSLayoutConstraint(item: alertView.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 400)

        alertView.view.addConstraint(confirmViewHeight)
        alertView.view.addConstraint(confirmViewWidth)

        let confirmButton = UIAlertAction(title: "Return to Chat", style: .default, handler: nil)

        alertView.addAction(confirmButton)

        self.present(alertView, animated: true, completion: nil)
    }
    
    func closeConnection() {
        self.webSocketTask.cancel(with: .goingAway, reason: nil)
        performSegue(withIdentifier: "backToMainMenu", sender: self)
    }
    
    //Moves View up on keyboard appearances
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    //Moves View down on keyboard dissappearances
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatMessageTableViewCell", for: indexPath) as! ChatMessageTableViewCell
        let messageContent = self.chatMessages[indexPath.row]
        
        cell.Icon.layer.cornerRadius = cell.Icon.frame.width / 2.0
        
        cell.Username.text = "\(messageContent.userName)"
        cell.Username.adjustsFontSizeToFitWidth = true
        cell.Username.minimumScaleFactor = 0.5
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss MM-dd-yyyy"
        cell.Time.text = formattedTime(formatter.string(from: messageContent.messageTime))
        cell.Time.adjustsFontSizeToFitWidth = true
        cell.Time.minimumScaleFactor = 0.5
        
        cell.Message.text = messageContent.message
        cell.Message.adjustsFontSizeToFitWidth = true
        cell.Message.minimumScaleFactor = 0.5
        
        
        let session = URLSession(configuration: .default)
        let httpClient = HTTPClient(session: session)
        
        let messageUser = httpClient.issueGETRequest(url: Constants.GETRequests[1], name: messageContent.userName, password: "")
        cell.Icon.image = UIImage(named: "avatar_\(messageUser.userIcon).png")
        
        return cell
    }
    
    func formattedTime(_ string: String) -> String{
        
        
        let databaseDate = String(string.suffix(10))
        let actualDate = String(date!.suffix(10))
//        print(databaseDate)
//        print(actualDate)
//        return ""
        let databaseDay = Int(String(databaseDate.prefix(2)))!
        let actualDay = Int(String(actualDate.prefix(2)))!

        let oldMonthYesterday = ((databaseDay == 31) || (databaseDay == 30) || (databaseDay == 29) || (databaseDay == 28)) && (actualDay == 1)

        if (databaseDay == actualDay) {
            return timeToLabel(string, addition: "Today at")
        }
        else if (((databaseDay - actualDay) == -1) || oldMonthYesterday) {
             return timeToLabel(string, addition: "Yesterday at")
        }
        else {
            let year = Int(String(databaseDate.prefix(4)))!
            let monthAndDay = String(databaseDate.suffix(5))
            let month = Int(String(monthAndDay.prefix(2)))!
            let day = Int(String(monthAndDay.suffix(2)))!
            return String("\(month)/\(day)/\(year)")
        }
    }
    
    func timeToLabel(_ string:  String, addition: String) -> String{
        var time = string.prefix(9)
        let minuteAndSeconds = String(time.suffix(6))
        let minutes = String(minuteAndSeconds.prefix(2))
        time = time.prefix(8)
        let hour = Int(String(time.prefix(2)))!
        return String("\(addition) \(hour):\(minutes)")
    }
    
    //Renders for testing
    override func render(_ props: ChatroomSelectionViewControllerProps) {
        print("Wrong Render Called: ChatroomSelectionViewControllerProps")
     }
     
     override func render(_ props: ChatroomViewControllerProps) {
        date = formattedTime(props.databaseDate)
//        getMessages()
//        chatMessages = 
     }
     
     override func render(_ props: ChatControllerProps) {
         print("Wrong Render Called: ChatControllerProps")
     }
}
