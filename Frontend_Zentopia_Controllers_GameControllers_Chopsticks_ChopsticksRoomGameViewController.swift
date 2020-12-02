//
//  ChopsticksRoomGameViewController.swift
//  Zentopia
//
//  Created by Aubrey Uriel Sijo-Gonzalez on 11/7/20.
//  Copyright © 2020 Aubrey Uriel Sijo-Gonzalez. All rights reserved.
//

import Foundation
import UIKit

/**
    View controller for the chopsticks game view 
 ***/
class ChopsticksRoomGameViewController: ZentopiaViewController {
    var roomID: UInt?
    
    @IBOutlet weak var opponentLeftLabel: UILabel!
    @IBOutlet weak var opponentRightLabel: UILabel!
    
    @IBOutlet weak var myLeftLabel: UILabel!
    @IBOutlet weak var myRightLabel: UILabel!
    
    @IBOutlet weak var opponentRightImgView: UIImageView!
    @IBOutlet weak var opponentLeftImgView: UIImageView!
    
    @IBOutlet weak var myLeftImgView: UIImageView!
    @IBOutlet weak var myRightImgView: UIImageView!
        
    @IBOutlet weak var waitingLabel: UILabel!
    
    var addToOpponentLeftButton: ButtonClass!
    var addToOpponentRightButton: ButtonClass!
    var distributeButton: ButtonClass!
    
    let titleMessages = ["Game Alert", "Exit Game", "Opponent has left", "Room is full"]
    let alertMessages = ["Please choose one of your active hands", "Cannot give away chopsticks on this hand"]
        
    var player1: ChopstickPlayer!
    var player2: ChopstickPlayer!
    
    var myLeftNum: Int?
    var myRightNum: Int?
    
    var theirLeftNum: Int?
    var theirRightNum: Int?
    
    var handTapped: Int?
    
    var myNum: Int?
  
    var urlSession = URLSession(configuration: .default)
    var webSocketTask: URLSessionWebSocketTask!
    
    var turn = 1
    
    var max = 0
    var toDistribute = 0
    
    var toDistributeAttr: [Int] = [-1,0,0]
    
    var winner = 0
    
    var presenter: ChopsticksRoomGameViewPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter?.onViewLoaded()
        
        self.displayWaitLabel()
        self.setUpLabels()
        
        self.openConnection()
    }
    
    func displayWaitLabel() {
        let backButton = ExitChopsticksRoomButton(color: UIColor(.LIGHTGREY), text: "Exit Game Room", width: xValue(180.0), height: yValue(50.0))
        
        self.view.addSubview(backButton)
        
        backButton.moveRect(newX: xCenter - xValue(110.0), newY: yCenter - yValue(360.0))
        
        self.waitingLabel.numberOfLines = 2
        self.waitingLabel.text = "Waiting for another player..."
        Utilities.styleGameLabel(self.waitingLabel)
    }

/*******
     
     
     
        VIEW STYLING FUNCTIONS
     
     
     
*****/
    func setUpLabels() {
        self.myLeftLabel.text    = ""
        self.myRightLabel.text   = ""
        
        self.opponentLeftLabel.text  = ""
        self.opponentRightLabel.text = ""
        
        Utilities.styleGameLabel(self.myLeftLabel)
        Utilities.styleGameLabel(self.myRightLabel)

        Utilities.styleGameLabel(self.opponentLeftLabel)
        Utilities.styleGameLabel(self.opponentRightLabel)
    }
    
    func setUpViewButtons() {
        self.addToOpponentLeftButton = AddToOpponentLeftButton(color: UIColor(.BLUE), text: "Add to Their Left", width: xValue(180.0), height: yValue(50.0))
        self.addToOpponentRightButton = AddToOpponentRightButton(color: UIColor(.BLUE), text: "Add to Their Right", width: xValue(180.0), height: yValue(50.0))
        self.distributeButton = DistributeChopsticksButton(color: UIColor(.ORANGE), text: "Distribute Chopsticks", width: xValue(180.0), height: yValue(50.0))
        
        self.view.backgroundColor = UIColor(.PASTY)
        self.view.addSubview(addToOpponentLeftButton)
        self.view.addSubview(addToOpponentRightButton)
        self.view.addSubview(distributeButton)
        
        self.addToOpponentLeftButton.moveRect(newX: xCenter + xValue(110.0), newY: yCenter - yValue(50.0))
        self.addToOpponentRightButton.moveRect(newX: xCenter - xValue(110), newY: yCenter - yValue(50.0))
        self.distributeButton.moveRect(newX: xCenter, newY: yCenter + yValue(20.0))
        
        self.disableButton(button: distributeButton)
    }
    
    func setNameLabels() {
        let theirNameLabel = Label(width: xValue(250.0), height: yValue(100.0), title: Constants.currentUser, style: Utilities.LabelType.INFO)
        let myNameLabel = Label(width:xValue(250.0), height: yValue(100.0), title: Constants.currentUser, style: Utilities.LabelType.INFO)
                        
        Utilities.styleGameLabel(theirNameLabel)
        Utilities.styleGameLabel(myNameLabel)
        
        self.view.addSubview(theirNameLabel)
        self.view.addSubview(myNameLabel)
        
        
        if(self.myNum == 1) {
            theirNameLabel.text = self.player2.userName
            myNameLabel.text    = self.player1.userName
        } else {
            theirNameLabel.text = self.player1.userName
            myNameLabel.text    = self.player2.userName
        }
        
        theirNameLabel.moveRect(newX: xCenter, newY: yCenter - yValue(300.0))
        myNameLabel.moveRect(newX: xCenter, newY: yCenter + yValue(230.0))
    }
    
    func setUpHands() {
        self.handTapped = 0
        
        let leftGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(leftHandImgViewTapped(leftGestureRecognizer:)))
        self.enableImgView(imgView: myLeftImgView)
        myLeftImgView.addGestureRecognizer(leftGestureRecognizer)
        
        let rightGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(rightHandImgViewTapped(rightGestureRecognizer:)))
        self.enableImgView(imgView: myRightImgView)
        myRightImgView.addGestureRecognizer(rightGestureRecognizer)
    }
    
    func disableImgView(imgView: UIImageView) {
        imgView.isUserInteractionEnabled = false
    }
    
    func enableImgView(imgView: UIImageView) {
        imgView.isUserInteractionEnabled = true
    }
    
    @objc func leftHandImgViewTapped(leftGestureRecognizer: UITapGestureRecognizer) {
        self.handTapped = 1
        
        if(self.myLeftNum! > 1 && self.myLeftNum! < 5) {
            self.enableButton(button: self.distributeButton, color: UIColor(.ORANGE))
        } else {
            self.disableButton(button: self.distributeButton)
        }

        dehighlightImgView(imgView: myRightImgView)
        
        if(self.myLeftNum != 5) {
            highlightImgView(imgView: myLeftImgView)
        }
    }

    @objc func rightHandImgViewTapped(rightGestureRecognizer: UITapGestureRecognizer) {
        self.handTapped = 2
            
        if(self.myRightNum! > 1 && self.myRightNum! < 5) {
            self.enableButton(button: self.distributeButton, color: UIColor(.ORANGE))
        } else {
            self.disableButton(button: self.distributeButton)
        }
        
        dehighlightImgView(imgView: myLeftImgView)
        
        if(self.myRightNum != 5) {
            highlightImgView(imgView: myRightImgView)
        }
    }
    
    func highlightImgView(imgView: UIImageView) {
        imgView.layer.borderWidth = 5
        imgView.layer.cornerRadius = 5
        imgView.layer.borderColor = UIColor(.GREEN).cgColor
    }
    
    func dehighlightImgView(imgView: UIImageView) {
        imgView.layer.borderWidth = 0
    }
    
    func updatePlayer(player: ChopstickPlayer) {
        if(player.playerNum == 1) {
            self.player1.leftHand   = player.leftHand
            self.player1.rightHand  = player.rightHand
        } else {
            self.player2.leftHand   = player.leftHand
            self.player2.rightHand  = player.rightHand
        }
    }
    
    func updateButtons() {
        if(self.theirLeftNum == 5 || self.theirLeftNum == 0) {
            self.disableButton(button: self.addToOpponentLeftButton)
        } else {
            self.enableButton(button: self.addToOpponentLeftButton, color: UIColor(.BLUE))
        }
        
        if(self.theirRightNum == 5 || self.theirRightNum == 0) {
            self.disableButton(button: self.addToOpponentRightButton)
        } else {
            self.enableButton(button: self.addToOpponentRightButton, color: UIColor(.BLUE))
        }
    }
    
    func disableButton(button: ButtonClass) {
        button.isUserInteractionEnabled = false
        button.colorView(UIColor(.LIGHTGREY))
    }
    
    func enableButton(button: ButtonClass, color: UIColor) {
        button.isUserInteractionEnabled = true
        button.colorView(color)
    }
    
    func updateImgViews() {
        var myLeftHand  = self.player1.leftHand
        var myRightHand = self.player1.rightHand
        
        var theirLeftHand   = self.player2.leftHand
        var theirRightHand  = self.player2.rightHand
        
        if(self.myNum == 2) {
            myLeftHand  = self.player2.leftHand
            myRightHand = self.player2.rightHand
            
            theirLeftHand   = self.player1.leftHand
            theirRightHand  = self.player1.rightHand
        }
        
        let myLeftImg   = UIImage(named: "\(myLeftHand)_my_hand.jpg")
        let myRightImg  = UIImage(named: "\(myRightHand)_my_hand.jpg")
        
        let theirLeftImg    = UIImage(named: "\(theirLeftHand)_their_hand.jpg")
        let theirRightImg   = UIImage(named: "\(theirRightHand)_their_hand.jpg")

        self.opponentRightImgView.image  = theirRightImg
        self.opponentLeftImgView.image   = theirLeftImg?.withHorizontallyFlippedOrientation()

        self.myLeftImgView.image     = myLeftImg?.withHorizontallyFlippedOrientation()
        self.myRightImgView.image    = myRightImg
    }
    
    func updateLabels() {
        self.myLeftLabel.text   = "\(self.myLeftNum ?? 0)"
        self.myRightLabel.text  = "\(self.myRightNum ?? 0)"
        
        self.opponentLeftLabel.text  = "\(self.theirLeftNum ?? 0)"
        self.opponentRightLabel.text = "\(self.theirRightNum ?? 0)"
        
        if(self.myLeftNum!  == 0    || self.myLeftNum!  == 5)   {self.myLeftLabel.textColor = UIColor(.RED)}
        if(self.myRightNum! == 0    || self.myRightNum! == 5)   {self.myRightLabel.textColor = UIColor(.RED)}
        
        if(self.theirLeftNum!   == 0    || self.theirLeftNum!   == 5)   {self.opponentLeftLabel.textColor = UIColor(.RED)}
        if(self.theirRightNum!  == 0    || self.theirRightNum!  == 5)   {self.opponentRightLabel.textColor = UIColor(.RED)}
    }

/*******
     
     
     
       WEBSOCKET SERVICES
     
     
     
*****/
    func openConnection() {
        // For debugging purposes
//        Constants.currentUser = "shalloubegin"
        
        let url = URL(string: "\(Constants.wsRoot)/chopstickroom?id=\(roomID ?? 1)&userName=\(Constants.currentUser)")
        self.webSocketTask = self.urlSession.webSocketTask(with: url!)
        self.listen()
        self.webSocketTask.resume()
    }
    
    func listen() {
        self.webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                print("Error received: \(error)")
            
            case .success(let users):
                switch users {
                case .string(let text):
                    print("Received string: \(text)")
                    
                    let usersArray = try? JSONDecoder().decode([ChopstickPlayer].self, from: text.data(using: .utf8)!)
                    let user = try? JSONDecoder().decode(ChopstickPlayer.self, from: text.data(using: .utf8)!)
                    
                    if(usersArray != nil) {
                        DispatchQueue.main.async {
                            self.player1 = usersArray![0]
                            self.player2 = usersArray![1]
                                                        
                            self.setUpViewButtons()

                            if(self.player1.userName == Constants.currentUser) {
                                self.myNum = 1
                            } else {
                                self.waitNextTurn()
                                self.myNum = 2
                            }
                            
                            self.waitingLabel.text = ""
                            
                            self.setNameLabels()
                            self.setUpHands()
                            
                            self.turn = 1
                            
                            self.playSequence()
                        }
                    } else if (user != nil) {
                        DispatchQueue.main.async {
                            self.updatePlayer(player: user!)
                            self.playSequence()
                            
                            self.turn = (self.turn % 2) + 1
                            
                            if(self.turn == self.myNum) {
                                self.enableImgView(imgView: self.myLeftImgView)
                                self.enableImgView(imgView: self.myRightImgView)
                                
                                self.updateButtons()
                            } else {
                                self.waitNextTurn()
                            }
                            
                            if(self.checkGameWon()) {
                                self.completeGame()
                            }
                        }
                    } else if (text == "Game over") {
                        DispatchQueue.main.async {
                            if(self.checkGameWon()) {
                                self.completeGame()
                            } else {
                                self.displayAlertView(titleMessage: self.titleMessages[2], alertMessage: "Please leave game room")
                            }
                        }
                    } else if (text == "Room is full") {
                        DispatchQueue.main.async {
                            self.displayAlertView(titleMessage: text, alertMessage: "Please leave and select a different room")
                        }
                    } else {
                        print("Unable to parse JSON response")
                    }
                    
                case .data(let data):
                    print("Received data: \(data)")
                    
                @unknown default:
                   fatalError()
                }
            }
            
            self.listen()
        }
    }
    
    func playSequence() {
        self.gethands()
        
        self.updateImgViews()
        
        self.setUpLabels()
        self.updateLabels()
    }
    
    func playTurn(buttonTapped: Character) {
        let result = computeHands(buttonTapped: buttonTapped, left: 0, right: 0)
        
        if(result[0] == -1) {
            return
        }
        
        print(result)
        let jsonString = """
        
        { "playerNum": \(result[0]), "leftHand": \(result[1]), "rightHand": \(result[2])}
        
        """
        
        let user = URLSessionWebSocketTask.Message.string(jsonString)
        self.webSocketTask.send(user) { error in
            if let error = error {
                print("Websocket sending error: \(error)")
            } else {
                print("Player info sent")
            }
        }
    }
    
    func performDistribution() {
        let jsonString = """
        
        { "playerNum": \(self.toDistributeAttr[0]), "leftHand": \(self.toDistributeAttr[1]), "rightHand": \(self.toDistributeAttr[2])}
        
        """
        
        let user = URLSessionWebSocketTask.Message.string(jsonString)
        self.webSocketTask.send(user) { error in
            if let error = error {
                print("Websocket sending error: \(error)")
            } else {
                print("Player info sent")
            }
        }
        
        self.toDistributeAttr[0] = -1
        self.toDistributeAttr[1] = 0
        self.toDistributeAttr[2] = 0
    }
    
    func waitNextTurn() {
        self.dehighlightImgView(imgView: self.myLeftImgView)
        self.dehighlightImgView(imgView: self.myRightImgView)
        
        self.disableImgView(imgView: self.myLeftImgView)
        self.disableImgView(imgView: self.myRightImgView)
        
        self.disableButton(button: self.addToOpponentLeftButton)
        self.disableButton(button: self.addToOpponentRightButton)
        self.disableButton(button: self.distributeButton)
    }
    
    func exitBeforeGameFinish(alertAction: UIAlertAction) {
        self.closeConnection()
        performSegue(withIdentifier: "ChopticksRoomSelectViewSegue", sender: self)
    }
    
    func completeGame() {
        self.closeConnection()
        // segue into different view
        performSegue(withIdentifier: "ChopsticksGameFinishViewSegue", sender: self)
    }
    
    /**
        Pass necessary data to SlidePuzzleGameWonViewController while performing segue to the Game Won view
     **/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ChopsticksGameFinishViewSegue"
        else
        {
            return
        }
        
        let props = ChopsticksGameFinishViewProps(myNum: self.myNum!, winner: self.winner, player1: self.player1.userName, player2: self.player2.userName)

        let vc = segue.destination as! ChopsticksGameFinishViewController

        vc.render(props)
    }
    
    func closeConnection() {
        self.webSocketTask.cancel(with: .goingAway, reason: nil)
    }
    
/*******
 
 
 
     GAME LOGIC
     
 
 
*****/
    func gethands() {
        if(self.myNum == 1) {
            self.myLeftNum  = self.player1.leftHand
            self.myRightNum = self.player1.rightHand
            
            self.theirLeftNum   = self.player2.leftHand
            self.theirRightNum  = self.player2.rightHand
        } else {
            self.myLeftNum  = self.player2.leftHand
            self.myRightNum = self.player2.rightHand
            
            self.theirLeftNum   = self.player1.leftHand
            self.theirRightNum  = self.player1.rightHand
        }
    }
    
    func computeHands(buttonTapped: Character, left: Int, right: Int) -> [Int] {
        var X = 0
        
        var doCompute = 1
        
        // toReturn[playerNum, leftHand, rightHand]
        var toReturn: [Int] = [-1, 0, 0]
        
        self.gethands()
        
        if(handTapped == 1) {
            X = self.myLeftNum!
        } else if(handTapped == 2) {
            X = self.myRightNum!
        } else {
            doCompute = 0
            _ = self.displayAlertView(titleMessage: self.titleMessages[0], alertMessage: self.alertMessages[0])
            return toReturn
        }
        
        if(doCompute == 1) {
            // add to one of your opponent's hands
            if(buttonTapped == "l" || buttonTapped == "r") {
                if(self.myNum == 1) {
                    toReturn[0] = 2
                } else {
                    toReturn[0] = 1
                }
                
                var result = 0
                
                if(buttonTapped == "l") {
                    // add to their left
                    if(X + self.theirLeftNum! > 5) {
                        result = (X + self.theirLeftNum!) - 5
                    } else {
                        result = X + self.theirLeftNum!
                    }
                    
                    toReturn[1] = result
                    toReturn[2] = self.theirRightNum!
                } else {
                    // add to their right
                    if(X + self.theirRightNum! > 5) {
                        result = (X + self.theirRightNum!) - 5
                    } else {
                        result = X + self.theirRightNum!
                    }
                     
                    toReturn[1] = self.theirLeftNum!
                    toReturn[2] = result
                }
            } else {
                // distribute among your hands
                if(X < 2) {
                    displayAlertView(titleMessage: self.titleMessages[0], alertMessage: self.alertMessages[1])
                    return toReturn
                } else {
                    self.max = (X-1)
                    
                    displayAlertView(titleMessage: self.titleMessages[0], alertMessage: "Select a number between 1 to \(self.max)")
                }
            }
        }
        
        return toReturn
    }
    
    func setToDistribute1(alertAction: UIAlertAction) {
        self.toDistribute = 1
        setDistributeAttr()
    }
    func setToDistribute2(alertAction: UIAlertAction) {
        self.toDistribute = 2
        setDistributeAttr()
    }
    func setToDistribute3(alertAction: UIAlertAction) {
        self.toDistribute = 3
        setDistributeAttr()
    }
    
    func setDistributeAttr() {
        print("toDistribute: \(self.toDistribute)")
            
        self.toDistributeAttr[0] = self.myNum!
        
        var result = 0
        
        if(handTapped == 1) {
            if(self.toDistribute + self.myRightNum! > 5) {
                result = (self.toDistribute + self.myRightNum!) - 5
            } else {
                result = self.toDistribute + self.myRightNum!
            }
            
            self.toDistributeAttr[1] = self.myLeftNum! - self.toDistribute
            self.toDistributeAttr[2] = result
        } else {
            if(self.toDistribute + self.myLeftNum! > 5) {
                result = (self.toDistribute + self.myLeftNum!) - 5
            } else {
                result = self.toDistribute + self.myLeftNum!
            }
            
            self.toDistributeAttr[1] = result
            self.toDistributeAttr[2] = self.myRightNum! - self.toDistribute
        }
        
        performDistribution()
        
        self.toDistribute = 0
        self.max = 0
    }
  
    func checkGameWon() -> Bool{
        let iLost       = (self.myLeftNum == 5 && self.myRightNum == 5)
        let theyLost    = (self.theirLeftNum == 5 && self.theirRightNum == 5)
        
        if(iLost || theyLost) {
            if(iLost) {
                self.winner = (self.myNum! % 2) + 1
            } else {
                self.winner = self.myNum!
            }
            
            return true
        }
        
        return false
    }
    
    func displayAlertView(titleMessage: String, alertMessage: String){
        let alertView = UIAlertController(title: titleMessage, message: alertMessage, preferredStyle: .alert)
        
        let confirmGameButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
        let cancelDistributeButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        var buttonNumForDistribute = 0
        
        if(titleMessage == self.titleMessages[0]) {
            if(alertMessage == self.alertMessages[0] || alertMessage == self.alertMessages[1]){
                alertView.addAction(confirmGameButton)
            } else {
                let button1 = UIAlertAction(title:"1", style: .default, handler: setToDistribute1)
                let button2 = UIAlertAction(title:"2", style: .default, handler: setToDistribute2)
                let button3 = UIAlertAction(title:"3", style: .default, handler: setToDistribute3)

                alertView.addAction(button1)
                if(self.max == 2 || self.max == 3) {
                    alertView.addAction(button2)
                }
                if(self.max == 3) {
                    alertView.addAction(button3)
                }
                
                alertView.addAction(cancelDistributeButton)
                
                buttonNumForDistribute = self.max
            }
        }
        
        let confirmExitButton = UIAlertAction(title: "Yes, I must leave.", style: .destructive, handler: exitBeforeGameFinish)
        let cancelExitButton = UIAlertAction(title: "No, keep me in the game.", style: .default, handler: nil)
        
        if(titleMessage == self.titleMessages[1]) {
            alertView.addAction(confirmExitButton)
            alertView.addAction(cancelExitButton)
        }
        
        let leaveRoomButton = UIAlertAction(title: "Leave Game Room", style: .default, handler: exitBeforeGameFinish)
        
        if(titleMessage == self.titleMessages[2] || titleMessage == self.titleMessages[3]) {
            print("\tadd leave room button")
            alertView.addAction(leaveRoomButton)
        }
        
        let confirmViewHeight = NSLayoutConstraint(item: alertView.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (CGFloat(150 + (buttonNumForDistribute * 30))))
        let confirmViewWidth = NSLayoutConstraint(item: alertView.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 400)
        
        alertView.view.addConstraint(confirmViewHeight)
        alertView.view.addConstraint(confirmViewWidth)

        self.present(alertView, animated: true, completion: nil)
    }
}

extension ChopsticksRoomGameViewController: ChopsticksRoomGameViewComponent {
    func render(_ props: ChopsticksRoomGameViewProps) {
        self.roomID = props.roomID
    }
}
