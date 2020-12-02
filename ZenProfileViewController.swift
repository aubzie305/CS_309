//
//  ZenProfileVIewController.swift
//  Zentopia
//
//  Created by Aubrey Uriel Sijo-Gonzalez on 9/29/20.
//  Copyright © 2020 Aubrey Uriel Sijo-Gonzalez. All rights reserved.
//

import Foundation
import UIKit

/**
    View controller for the Zen Profile View
 ***/
class ZenProfileViewController: ZentopiaViewController {
    
    @IBOutlet weak var profilePictureView: UIImageView!
   
    @IBOutlet weak var namePlacerLabel: UILabel!
    @IBOutlet weak var statusPlacerLabel: UILabel!
    @IBOutlet weak var memberSincePlacerLabel: UILabel!
    @IBOutlet weak var zenLevelPlacerLabel: UILabel!
    
    @IBOutlet weak var zenNameLabel: UILabel!
    @IBOutlet weak var zenStatusLabel: UILabel!
    @IBOutlet weak var zenMemberSinceLabel: UILabel!
    @IBOutlet weak var zenLevelLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var statsContainer: UIView!
    
    var currentZenUser:ZenUser!
    
    /**
        Calls functions to set up view design
     **/
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Constants.currentUser = "erykahbadu" //For debugging purposes
        
        let session = URLSession(configuration: .default)

        let httpClient = HTTPClient(session: session)

        currentZenUser = httpClient.issueGETRequest(url: Constants.GETRequests[1], name: Constants.currentUser, password: "")
        
        setUpViewLabels()
        setUpViewButtons()
        displayProfile()
    }
    
    /**
        Programmatically add buttons to view with design
     **/
    func setUpViewButtons() {
        let backButton = ButtonClass(color: UIColor(.LIGHTGREY), text: "Back", segue: "backToMainMenu", width: xValue(50.0), height: yValue(35.0))
        let settingsButton = ButtonClass(color: UIColor(.YELLOW), text: "Account Settings", segue: "ZenAccountSettingsViewSegue", width: xValue(160.0), height: yValue(35.0))
        
        self.view.addSubview(backButton)
        self.view.addSubview(settingsButton)
        
        backButton.moveRect(newX: xCenter - xValue(160.0), newY: yCenter - yValue(360.0))
        settingsButton.moveRect(newX: xCenter + xValue(120.0), newY: yCenter - yValue(360.0))
    }
    
    /***
        Programmatically add header and title labels to the view
     **/
    func setUpViewLabels() {
        Utilities.styleHeaderLabel(namePlacerLabel)
        Utilities.styleHeaderLabel(statusPlacerLabel)
        Utilities.styleHeaderLabel(zenLevelPlacerLabel)
        
        Utilities.styleTitleLabel(zenNameLabel)
        Utilities.styleTitleLabel(zenStatusLabel)
        Utilities.styleTitleLabel(memberSincePlacerLabel)
        Utilities.styleTitleLabel(zenMemberSinceLabel)
    }
    
    /**
        Display the ZenUser's profile with their attributes and level statistics
     ***/
    func displayProfile() {
        profilePictureView.image = UIImage(named: String(format: "avatar_\(currentZenUser.userIcon)"))
        
        zenNameLabel.text = currentZenUser.userName
        
        zenLevelLabel.text = "\(currentZenUser.totalPoints ?? 0)"
        
        if(currentZenUser.userLevel == 1) {
            zenStatusLabel.text = "Amateur Yogi"
            zenLevelLabel.text! += "/200"
        }
        else if (currentZenUser.userLevel == 2) {
            zenStatusLabel.text = "Savasana Pro"
            zenLevelLabel.text! += "/300"
        }
        else {
            zenStatusLabel.text = "Nirvana Expert"
        }
        
        zenMemberSinceLabel.text = readableDate(fullDate: currentZenUser.joinedAt)
    }
    
    
    /**
        Helper function to make 'joinedAt' attribute of a ZenUser model readable
     **/
    func readableDate(fullDate: String) -> String {
        var simpleDate = ""
        
        let dateArr = Array(fullDate)
        let year = String(dateArr[0...3])
        let month = Int(String(dateArr[5...6])) ?? 0
        let day = String(dateArr[8...9])
        
        let MONTHS:[String] = ["Jan", "Feb", "March", "April", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"]
        
        simpleDate += "\(MONTHS[month - 1]) \(day), \(year)"
        
        return simpleDate
    }
}
