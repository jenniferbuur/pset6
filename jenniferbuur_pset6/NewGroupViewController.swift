//
//  newGroupViewController.swift
//  jenniferbuur_pset6
//
//  Created by Jennifer Buur on 19-03-17.
//  Copyright © 2017 Jennifer Buur. All rights reserved.
//

import UIKit
import Firebase

class NewGroupViewController: UIViewController {
    
    @IBOutlet var groupName: UITextField!
    @IBOutlet var memberName: UITextField!
    @IBOutlet var memberView: UITextView!
    var ref: FIRDatabaseReference!
    var handle: FIRAuthStateDidChangeListenerHandle?
    var user = FIRAuth.auth()?.currentUser
    var members = [String]()
    
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
            self.alertUser(title: "Something went wrong", message: "Please try again")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let handle = handle else { return }
        
        FIRAuth.auth()?.removeStateDidChangeListener(handle)
    }
    
    @IBAction func addMember(_ sender: Any) {
        members.append(memberName.text!)
        memberView.isEditable = false
        memberView.text = String(describing: members)
    }
    
    @IBAction func saveGroup(_ sender: Any) {
        guard let user = user else { return }
        
        let group = ref.child(user.uid).child("groups").childByAutoId()
        group.setValue(["name": groupName.text!])
//        for member in members {
//            group.setValue(member)
//            group.child(member).setValue(0)
//        }
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
