//
//  ZenAccountSettingsViewController.swift
//  Zentopia
//
//  Created by Aubrey Uriel Sijo-Gonzalez on 9/29/20.
//  Copyright © 2020 Aubrey Uriel Sijo-Gonzalez. All rights reserved.
//

import Foundation
import UIKit

/**
    View controller for Zen Account Settings view
 ***/
class ZenAccountSettingsViewController: ZentopiaViewController {
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var changeAvatarLabel: UILabel!
    @IBOutlet weak var changePasswordLabel: UILabel!
    
    @IBOutlet weak var curPasswordLabel: UILabel!
    @IBOutlet weak var newPasswordLabel: UILabel!
    @IBOutlet weak var confirmNewPasswordLabel: UILabel!
    
    @IBOutlet weak var curPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    
    @IBOutlet weak var imgView1: UIImageView!
    @IBOutlet weak var imgView2: UIImageView!
    @IBOutlet weak var imgView3: UIImageView!
    @IBOutlet weak var imgView4: UIImageView!
    
    var curAvatarSelected: Int!
    
    var session: URLSession!
    var httpClient: HTTPClient!
    
    /**
        Calls functions to set up view design
     ***/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViewButtons()
        setUpAvatars()
        setUpViewLabelsAndFields()
        
        session = URLSession(configuration: .default)
        httpClient = HTTPClient(session: session)
        
        curAvatarSelected = 0
    }
    
    /**
        Progammatically add buttons to view with design
     ***/
    func setUpViewButtons() {
        let backToProfileButton = ButtonClass(color: UIColor(.LIGHTGREY), text: "Back to Profile", segue: "ProfileViewSegue", width: xValue(150.0), height: yValue(35.0))
        let deleteZenAccountButton = DeleteAccountButton(color: UIColor(.RED), text: "Delete Zen Account", width: xValue(180.0), height: yValue(50.0))
        let confirmButton = ConfirmAccountChangesButton(color: UIColor(.BLUE), text: "Confirm Changes", width: xValue(130.0), height: yValue(50.0))
        
        self.view.addSubview(backToProfileButton)
        self.view.addSubview(deleteZenAccountButton)
        self.view.addSubview(confirmButton)
        
        backToProfileButton.moveRect(newX: xCenter - xValue(110.0), newY: yCenter - yValue(360.0))
        deleteZenAccountButton.moveRect(newX: xCenter - xValue(100.0), newY: yCenter + yValue(200.0))
        confirmButton.moveRect(newX: xCenter + xValue(120), newY: yCenter + yValue(200.0))
    }
   
    /**
        Programmatically add labels and text fields onto view
     ***/
    func setUpViewLabelsAndFields() {
        Utilities.styleHeaderLabel(viewTitleLabel)
        Utilities.styleHeaderLabel(changeAvatarLabel)
        Utilities.styleHeaderLabel(changePasswordLabel)
        
        Utilities.styleTitleLabel(curPasswordLabel)
        Utilities.styleTitleLabel(newPasswordLabel)
        Utilities.styleTitleLabel(confirmNewPasswordLabel)
        
        Utilities.styleTextField(curPasswordTextField)
        Utilities.styleTextField(newPasswordTextField)
        Utilities.styleTextField(confirmNewPasswordTextField)
        
        curPasswordTextField.text = ""
        newPasswordTextField.text = ""
        confirmNewPasswordTextField.text = ""
    }
    
    /**
        Set up avatar options for user
        Limit options according to the currentZenUser's level
     ***/
    func setUpAvatars() {
        imgView1.image = UIImage(named: "avatar_1.png")
        
        let tap1GestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(image1Tapped(tap1GestureRecognizer:)))
        imgView1.isUserInteractionEnabled = true
        imgView1.addGestureRecognizer(tap1GestureRecognizer)
        
        if(Constants.currentZenUser.userLevel > 1) {
            imgView2.image = UIImage(named: "avatar_2.png")
            imgView3.image = UIImage(named: "avatar_3.png")

            let tap2GestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(image2Tapped(tap2GestureRecognizer:)))
            imgView2.isUserInteractionEnabled = true
            imgView2.addGestureRecognizer(tap2GestureRecognizer)

            let tap3GestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(image3Tapped(tap3GestureRecognizer:)))
            imgView3.isUserInteractionEnabled = true
            imgView3.addGestureRecognizer(tap3GestureRecognizer)
        } else {
            imgView2.image = UIImage(named: "locked.png")
            imgView3.image = UIImage(named: "locked.png")
        }

        if(Constants.currentZenUser.userLevel < 3) {
            imgView4.image = UIImage(named: "locked.png")
        } else {
            imgView4.image = UIImage(named: "avatar_4.png")
            let tap4GestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(image4Tapped(tap4GestureRecognizer:)))
            imgView4.isUserInteractionEnabled = true
            imgView4.addGestureRecognizer(tap4GestureRecognizer)
        }
    }
    
    /**
        Handles user interaction for image view
     **/
    @objc func image1Tapped(tap1GestureRecognizer: UITapGestureRecognizer){
        curAvatarSelected = 1
        
        highlightImgView(imgView: imgView1)
        
        dehighlightImgView(imgView: imgView2)
        dehighlightImgView(imgView: imgView3)
        dehighlightImgView(imgView: imgView4)
    }
    
    /**
       Handles user interaction for image view
    **/
    @objc func image2Tapped(tap2GestureRecognizer: UITapGestureRecognizer){
        curAvatarSelected = 2
        
        highlightImgView(imgView: imgView2)
        
        dehighlightImgView(imgView: imgView1)
        dehighlightImgView(imgView: imgView3)
        dehighlightImgView(imgView: imgView4)
    }
    
    /**
       Handles user interaction for image view
    **/
    @objc func image3Tapped(tap3GestureRecognizer: UITapGestureRecognizer){
        curAvatarSelected = 3
        
        highlightImgView(imgView: imgView3)
        
        dehighlightImgView(imgView: imgView1)
        dehighlightImgView(imgView: imgView2)
        dehighlightImgView(imgView: imgView4)
    }
    
    /**
       Handles user interaction for image view
    **/
    @objc func image4Tapped(tap4GestureRecognizer: UITapGestureRecognizer){
        curAvatarSelected = 4
        
        highlightImgView(imgView: imgView4)
        
        dehighlightImgView(imgView: imgView1)
        dehighlightImgView(imgView: imgView2)
        dehighlightImgView(imgView: imgView3)
    }
    
    /**
       Handles user interaction for image view
    **/
    func highlightImgView(imgView: UIImageView) {
        imgView.layer.borderWidth = 10
        imgView.layer.cornerRadius = 10
        imgView.layer.borderColor = UIColor(.ORANGE).cgColor
    }
    
    /**
       Handles user interaction for image view
    **/
    func dehighlightImgView(imgView: UIImageView) {
        imgView.layer.borderWidth = 0
    }
    
    /**
        Displays alert box to confirm deletion of zen account
     ***/
    func displayDeleteView() {
        var alertMessage: String = ""
        
        let passwordInput: String = curPasswordTextField.text!

        if(passwordInput.count == 0) {
            alertMessage += "Please enter password before deleting"
        } else if (passwordInput != Constants.currentZenUser.userPassword) {
            alertMessage += "Password is incorrect"
        }
        
        let deleteView = UIAlertController(title: "Delete Zen Account", message: alertMessage, preferredStyle: .alert)
            
        let deleteViewHeight = NSLayoutConstraint(item: deleteView.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 150)
        let deleteViewWidth = NSLayoutConstraint(item: deleteView.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 400)
        
        deleteView.view.addConstraint(deleteViewHeight)
        deleteView.view.addConstraint(deleteViewWidth)
        
        let confirmButton = UIAlertAction(title: "Confirm Deletion?", style: .destructive) { _ in
            self.httpClient.deleteZenAccount(zenUserName: Constants.currentUser)
            
            Constants.currentUser = ""
            Constants.currentZenUser = ZenUser.init()
            Constants.errorMessage = ""
            
            self.performSegue(withIdentifier: "HomeViewSegue", sender: self)
        }
        
        let returnButton = UIAlertAction(title: "Return", style: .cancel, handler: nil)
        
        if(alertMessage.count == 0) {
            deleteView.addAction(confirmButton)
        }
    
        deleteView.addAction(returnButton)
        
        self.present(deleteView, animated: true, completion: nil)
    }
    
    /**
        Calls changeIcon() from HTTPClient class to issue request to change the user's icon
     ***/
    func issueAccountChanges(alertAction: UIAlertAction) {
        if(curAvatarSelected != 0) {
            httpClient.changeIcon(zenUserName: Constants.currentUser, icon: curAvatarSelected)
        }
        
        let newPasswordInput: String = newPasswordTextField.text!

        if(newPasswordInput.count > 0) {
            httpClient.changePassword(zenUserName: Constants.currentUser, zenUserPassword: newPasswordInput)
        }
        
        self.performSegue(withIdentifier: "ProfileViewSegue", sender: self)
    }
    
    /**
        Helper function to inform user of requirements before confirming changes
        User must provide their current password before confirming any changes
        Invokes displayConfirmView()
     **/
    func getConfirmAlertMessage() {
        var alertMessage: String = ""
        
        let passwordInput: String = curPasswordTextField.text!
        let newPasswordInput: String = newPasswordTextField.text!
        let confirmNewPasswordInput: String = confirmNewPasswordTextField.text!
        
        if(curAvatarSelected == 0 && newPasswordInput.count == 0) {
            alertMessage += "Please select a change to make\n"
        }
        
        if(passwordInput != "") {
            if(passwordInput != Constants.currentZenUser.userPassword) {
                alertMessage += "Password is not correct\n"
            }
        } else {
            if(newPasswordInput.count != 0) {
                alertMessage += "Please provide your current password before confirming\n"
            }
        }
        
        if(newPasswordInput != "") {
            if(newPasswordInput != confirmNewPasswordInput) {
                alertMessage += "Please re-enter new password"
            }
        }
        
        displayConfirmView(alertMessage: alertMessage)
    }
    
    /**
        Display alert view for confirming changes
     ***/
    func displayConfirmView(alertMessage: String) {
        let confirmView = UIAlertController(title: "", message: alertMessage, preferredStyle: .alert)
        
        let confirmViewHeight = NSLayoutConstraint(item: confirmView.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 150)
        let confirmViewWidth = NSLayoutConstraint(item: confirmView.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 400)
        
        confirmView.view.addConstraint(confirmViewHeight)
        confirmView.view.addConstraint(confirmViewWidth)
        
        let confirmButton = UIAlertAction(title: "Confirm Changes", style: .default, handler: issueAccountChanges)
        let returnButton = UIAlertAction(title: "Return to Account Settings Page", style: .cancel, handler: nil)
        
        if(alertMessage.count == 0) {
            confirmView.view.removeConstraint(confirmViewHeight)
            confirmView.addAction(confirmButton)
        } else {
            confirmView.addAction(returnButton)
        }
        
        self.present(confirmView, animated: true, completion: nil)
    }
}
