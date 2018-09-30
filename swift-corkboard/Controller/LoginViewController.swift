//
//  LoginViewController.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 9/6/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import SwiftKeychainWrapper

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
//        usernameTextField.becomeFirstResponder()
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loginButtonPressed((Any).self)
        return true
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        SVProgressHUD.show()
        Alamofire.request("http://localhost:5000/login", method: .post, parameters: [ "username": usernameTextField.text!, "password": passwordTextField.text! ],encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            let data : JSON = JSON(response.result.value!)
            let token = data["token"]
            let userId = data["user_id"]
            let error = data["error"]
            self.defaults.set(token.stringValue, forKey: "token")
            self.defaults.set(userId.stringValue, forKey: "userId")
            print(userId)
            print(token)
            let saveToken: Bool = KeychainWrapper.standard.set(token.stringValue, forKey: "token")
            let saveUserId: Bool = KeychainWrapper.standard.set(userId.stringValue, forKey: "userId")
            print(saveToken)
            if token == JSON.null {
                print("Error: \(error)")
                SVProgressHUD.dismiss()
            } else {
                print("Login Success!")
                SVProgressHUD.dismiss()
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController")
                self.navigationController!.pushViewController(controller!, animated: true)
                
            }
        }
    }
    

}
