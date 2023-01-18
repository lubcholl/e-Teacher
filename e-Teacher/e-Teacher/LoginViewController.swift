//
//  LoginViewController.swift
//  e-Teacher
//
//  Created by Lyubomir on 7.01.23.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var pinTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    private var validUser = false
    private var validPass = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinTF.delegate = self
        passwordTF.delegate = self
        loginButton.isEnabled = false
        pinTF.accessibilityIdentifier = "Username"
        DataAPIManager.getToken()
        //DataAPIManager.userLogin() // crerates the auth token
    }
    
    @IBAction func logInButton(_ sender: UIButton) {
        doSignIn()
    }
    
    func doSignIn() {
        DataAPIManager.logInAdmin(id: pinTF.text!, pass: passwordTF.text!) { result in
            switch result {
            case .success(let adminData):
                Model.adminData = adminData
                DispatchQueue.main.async {
                    self.passwordTF.text = ""
                    self.performSegue(withIdentifier: "logIn", sender: nil)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logIn" {
            let backItem = UIBarButtonItem()
            backItem.title = "Изход"
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.accessibilityIdentifier == "Username" {
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            validUser = text.count >= 4
        } else {
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            validPass = text.count >= 4
        }
        loginButton.isEnabled = validUser && validPass
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == pinTF {
            passwordTF.becomeFirstResponder()
        } else if textField == passwordTF {
            passwordTF.resignFirstResponder()
            doSignIn()
        }
        return true
    }
}
