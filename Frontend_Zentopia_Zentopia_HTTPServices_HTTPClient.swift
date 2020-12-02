//
//  NetworkRequests.swift
//
//  Authors: Aubrey Uriel Sijo-Gonzales, Alexis Aurandt
//

import Foundation

/**
   Frontend library for network requests to backend server via Vapor API
 */
class HTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    /**
        Issues a GET request to verify user doesn't already exist in the database
        If user is non-existent, issue a POST request to add a new user to the database
        Returns 1 on success, 0 otherwise
     **/
    func performSignup(zenUserName: String, zenUserPassword: String)-> Int {
        let result = issuePOSTRequest(urlToAppend: Constants.POSTRequests[0], name: zenUserName, password: zenUserPassword, points: -1, icon: -1, chatID: -1, gameName: "", gameLevel: "")
        
        return result
    }
    
     /**
        Issues a GET request to extract existing user information from database to perform login
        Returns instance of currently logged in ZenUser
     **/
    func performLogin(zenUserName: String, zenUserPassword: String) -> ZenUser {
        // Reset user info
        let foundUser = issueGETRequest(url: Constants.GETRequests[2], name: zenUserName, password: zenUserPassword)
        
        if(foundUser.userName != "nilName") {
            Constants.currentUser = foundUser.userName
            Constants.currentZenUser = foundUser
        }
        
        return foundUser
    }
    
    /**
        Issues a POST request to update the users total points
     **/
    func updateZenPoints(zenUserName: String, pointsEarned: Int, gameName: String, gameLevel: String) {
        _ = issuePOSTRequest(urlToAppend: Constants.POSTRequests[4], name: zenUserName, password: "", points: pointsEarned, icon: -1, chatID: -1, gameName: gameName ,gameLevel: gameLevel)
    }
    
    /**
        Issues a POST request to delete the user's zen account
     */
    func deleteZenAccount(zenUserName: String) {
        _ = issuePOSTRequest(urlToAppend: Constants.POSTRequests[1], name: zenUserName, password: "", points: -1, icon: -1, chatID: -1, gameName: "", gameLevel: "")
    }
    
    /**
        Issues a POST request to change the user's icon
     */
    func changeIcon(zenUserName: String, icon: Int) {
        _ = issuePOSTRequest(urlToAppend: Constants.POSTRequests[2], name: zenUserName, password: "", points: -1, icon: icon, chatID: -1, gameName: "", gameLevel: "")
    }
    
    /**
        Issues a POST request to change the user's password
     */
    func changePassword(zenUserName: String, zenUserPassword: String) {
        _ = issuePOSTRequest(urlToAppend: Constants.POSTRequests[3], name: zenUserName, password: zenUserPassword, points: -1, icon: -1, chatID: -1, gameName: "", gameLevel: "")
    }
    
    /**
        Issues a GET request
        Returns an instance of a ZenUser: dummy user on fail, existing/valid user on success
     **/
    func issueGETRequest(url: String, name: String? = nil, password: String? = nil, userID: Int? = nil) -> ZenUser {
        var user:ZenUser = ZenUser()
        
        var urlString = "\(Constants.root)\(url)"
        if(url == Constants.GETRequests[2]) {
            urlString += "userName=\(name!)&userPassword=\(password!)"
        } else if(url == Constants.GETRequests[4]) {
            urlString += "userID=\(userID!)"
        }
        else{
            urlString += "userName=\(name!)"
        }
        
        let url = URL(string: urlString)!
        
        var requestComplete = 0
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }

            let decoder = JSONDecoder()
            
            let zenUser = try? decoder.decode(ZenUser.self, from: data)
        
            if(zenUser != nil) {
                user = zenUser!
            } else {
                print("Unable to parse JSON requests")
            }
            
            requestComplete = 1
        }.resume()
        
        // Wait till request is complete
        while(requestComplete == 0){}

        return user
    }
    
    /**
        Issues a POST request
        Returns an integer: 1 if successful, 0 if not
     */
    func issuePOSTRequest(urlToAppend: String, name: String, password: String, points: Int, icon: Int, chatID: Int, gameName: String, gameLevel: String) -> Int {
        
        var urlString = "\(Constants.root)\(urlToAppend)"
        
        if (urlToAppend == Constants.POSTRequests[1]) {
            urlString += "userName=\(name)"
        } else if (urlToAppend == Constants.POSTRequests[2]) {
            urlString += "userName=\(name)&icon=\(icon)"
        } else if (urlToAppend == Constants.POSTRequests[3]) {
            urlString += "userName=\(name)&userPassword=\(password)"
        } else if(urlToAppend == Constants.POSTRequests[4]) {
            urlString += "userName=\(name)&points=\(points)&complexityLevel=\(gameLevel)&gameName=\(gameName)"
        } else if (urlToAppend == Constants.POSTRequests[5]) {
            urlString += "id=\(chatID)"
        }
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let newZenUser = "userName=\(name)&userPassword=\(password)"
        if(urlToAppend == Constants.POSTRequests[0]) {
            request.httpBody = newZenUser.data(using: String.Encoding.utf8)
        }
        
        var dataString: String?
        var requestComplete = 0
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("ERROR: \(error)")
                return
            }
            if let data = data{
                dataString = String(data: data, encoding: .utf8)
                print("RESPONSE: \(String(dataString!))")
                DispatchQueue.main.async {
                    Constants.errorMessage = String(dataString!)
                }
            }
            requestComplete = 1
        }.resume()
        
        // Wait till request is complete
        while(requestComplete == 0){}
        if(dataString!.contains("Success")){
             Constants.currentUser = name
             Constants.currentZenUser = issueGETRequest(url: Constants.GETRequests[2], name: name, password: password)
             Constants.errorMessage = ""
             return Constants.SUCCESS
        }
        
        return Constants.FAIL
    }
}

/**
    Inject URLSession object type into HTTPClient
    Extension to make HTTPClient testable
 **/
extension URLSession: URLSessionProtocol {}

/**
    Inject URLSessionDataTask object type into URLSession
    Extension to make HTTPClient testable
**/
extension URLSessionDataTask: URLSessionDataTaskProtocol {}

