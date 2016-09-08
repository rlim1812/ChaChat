//
//  ViewController.swift
//  ChaChat
//
//  Created by Ryan Lim on 8/29/16.
//  Copyright © 2016 Ryan Lim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var messages : [FIRDataSnapshot]! = [FIRDataSnapshot]()
    
    var ref: FIRDatabaseReference! = FIRDatabaseReference()
    private var _refHandle: FIRDatabaseHandle
    
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //logout
        /*let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError{
            print("Error signing out")
        }*/
        
        if (FIRAuth.auth()?.currentUser == nil){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "firebaseLoginViewController")
            self.navigationController?.present(vc!, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.textField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        configureDatabase()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    
    
    func sendMessage(data: [String:String]){
        var packet = data
        packet[Constants.MessageFields.dateTime] = Utilities().getDate()
        self.ref.child("messages").childByAutoId().setValue(packet)
    }
    
    //code to remove observers when view disappears
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow , object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide , object: self.view.window)
        
    }
    
    //code to shift view up when keyboard shows 
    func keyboardWillShow(_ sender: NSNotification){
        let userInfo: [NSObject:AnyObject] = sender.userInfo!
        
        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]?.cgRectValue().size)!
        
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.cgRectValue().size
        
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                UIView.animate(withDuration: 0.15, animations: {
                    self.view.frame.origin.y -= keyboardSize.height
                })
            }
        } else {
            UIView.animate(withDuration: 0.15, animations: {
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
    }
    //code to shift view down when keyboard becomes hidden
    func keyboardWillHide(_ sender: Notification){
        let userInfo: [NSObject:AnyObject] = (sender as NSNotification).userInfo!
        
        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]?.cgRectValue().size)!
        
        self.view.frame.origin.y += keyboardSize.height
        
    }
    
    deinit {
        self.ref.child("messages").removeObserver(withHandle: _refHandle)
    }
    
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        
        _refHandle = self.ref.child("messages").observe(.childAdded, with: {(snapshot) -> Void in
        
            self.messages.append(snapshot)
            self.tableview.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
        } )
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableview.dequeueReusableCell(withIdentifier: "tableviewCell", for: indexPath)
        let messageSnap: FIRDataSnapshot = self.messages[indexPath.row]
        let message = messageSnap.value as! Dictionary<String, String>
        if let text = message[Constants.MessageFields.text] as String! {
        cell.textLabel?.text = text
        }
        if let subtext = message[Constants.MessageFields.dateTime] {
            cell.detailTextLabel?.text = subtext
        }
        return cell
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField.text?.characters.count == 0){
            return true
            
        }
        let data = [Constants.MessageFields.text: textField.text! as String]
        sendMessage(data: data)
        print("Ended Editing")
        textField.text = ""
        self.view.endEditing(true)
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

