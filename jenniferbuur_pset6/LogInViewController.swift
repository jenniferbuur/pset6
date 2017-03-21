//
//  LogInViewController.swift
//  jenniferbuur_pset6
//
//  Created by Jennifer Buur on 20-03-17.
//  Copyright © 2017 Jennifer Buur. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {

    @IBOutlet var eMail: UITextField!
    @IBOutlet var passWord: UITextField!
    
    var ref: FIRDatabaseReference!
    var handle: FIRAuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            if let user = user {
                self.performSegue(withIdentifier: "login", sender: user)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let handle = handle else { return }
        
        FIRAuth.auth()?.removeStateDidChangeListener(handle)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    @IBAction func logIn(_ sender: Any) {
        FIRAuth.auth()!.signIn(withEmail: eMail.text!, password: passWord.text!) { user, error in
            if error != nil {
                self.alertUser(title: "Invalid Log In", message: "Please try again!")
                return
            }
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        if eMail.text!.isEmpty {
            alertUser(title: "No username", message: "Please fill in a username.")
            return
        }
        if passWord.text!.isEmpty {
            alertUser(title: "No password", message: "Please fill in a password")
            return
        }
        FIRAuth.auth()!.createUser(withEmail: eMail.text!, password: passWord.text!) { user, error in
            if error == nil {
                FIRAuth.auth()!.signIn(withEmail: self.eMail.text!, password: self.passWord.text!)
            } else {
                self.alertUser(title: "Something went wrong", message: "Please try again!")
                print("\(error)")
                return
            }
        }
    }
    
    func alertUser(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        return
    }
}
