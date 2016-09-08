//
//  LoginRegisterViewController.swift
//  ChaChat
//
//  Created by Ryan Lim on 8/30/16.
//  Copyright © 2016 Ryan Lim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginRegisterViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func checkInput() -> Bool {
        if emailTextField.text?.characters.count < 5 {
            emailTextField.backgroundColor = UIColor.init(red: 0.8, green: 0, blue: 0, alpha: 0.2)
            return false
        } else {
            emailTextField.backgroundColor = UIColor.white()
        }
        
        if passwordTextField.text?.characters.count < 5 {
            passwordTextField.backgroundColor = UIColor.init(red: 0.8, green: 0, blue: 0, alpha: 0.2)
            return false
        } else {
            passwordTextField.backgroundColor = UIColor.white()
        }
        
        return true
    }

    @IBAction func login(_ sender: AnyObject) {

        if (!checkInput()){
            return
        }
        
        let email = emailTextField.text
        let password = passwordTextField.text
        
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!, completion: { (user, error) in
            if let error = error {
                Utilities().showAlert(title: "Error", message: error.localizedDescription, vc: self)
                print(error.localizedDescription)
                return
            } else {
                print("Signed In")
            }
        })
    }
    
    @IBAction func register(_ sender: AnyObject) {
        if (!checkInput()) {
           return
        }
        
        let alert = UIAlertController(title: "Register", message: "Please confirm password", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "password"
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let passConfirm = (alert.textFields?[0])! as UITextField
            if passConfirm.text!.isEqual(self.passwordTextField.text!){
                
                //registration begins
                let email = self.emailTextField.text!
                let password = self.passwordTextField.text!
                
                FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                    if let error = error {
                        Utilities().showAlert(title: "Error", message: error.localizedDescription, vc: self)
                        return
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                Utilities().showAlert(title: "Error", message: "Passwords not the same", vc: self)
            }
        }))
        self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func forgotPassword(_ sender: AnyObject) {
        if (!emailTextField.text!.isEmpty){
            let email = self.emailTextField.text
            FIRAuth.auth()?.sendPasswordReset(withEmail: email!, completion: { (error) in
                if let error = error {
                    Utilities().showAlert(title: "Error", message: error.localizedDescription, vc: self)
                    return
                } else {
                    Utilities().showAlert(title: "Success!", message: "Please check your email", vc: self)
                }
            })
        }
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn (_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
}
