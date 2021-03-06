//
//  PaymentViewController.swift
//  jenniferbuur_pset6
//
//  Created by Jennifer Buur on 19-03-17.
//  Copyright © 2017 Jennifer Buur. All rights reserved.
//

import UIKit
import Firebase

class PaymentViewController: UIViewController {

    @IBOutlet var amount: UITextField!
    var ref: FIRDatabaseReference!
    var handle: FIRAuthStateDidChangeListenerHandle?
    var user = FIRAuth.auth()?.currentUser
    var member = Int()
    var members = [String]()
    var balances = [Int]()
    var groupname = String()
    var amountInt = Int()
    var key = String()
    
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
            self.user = user
            
            if user == nil {
                self.alertUser(title: "Something went wrong", message: "Please try again")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let handle = handle else { return }
        
        FIRAuth.auth()?.removeStateDidChangeListener(handle)
    }
    
    @IBAction func addToBalance(_ sender: Any) {
        if (Int(amount.text!) == nil) {
            alertUser(title: "Not a valid amount", message: "Please fill in an valid amount")
            return
        } else {
            guard let user = user else { return }
            amountInt = Int(amount.text!)!
            let groups = ref.child(user.uid).child("groups")
            var handle: FIRDatabaseHandle? = nil
            handle = groups.observe(.value, with: {snapshot in
                if let handle = handle {
                    groups.removeObserver(withHandle: handle)
                }
                
                for child in snapshot.children {
                    let snapshotValue = (child as! FIRDataSnapshot).value as? NSDictionary
                    if snapshotValue?["name"] as! String == self.groupname {
                        self.key = (child as! FIRDataSnapshot).key
                    }
                }
                
                for index in 0..<self.balances.count {
                    if index != self.member {
                        self.balances[index] -= self.amountInt/self.balances.count
                    } else {
                        self.balances[index] += self.amountInt - self.amountInt/self.balances.count
                    }
                    self.ref.child(user.uid).child("groups").child(self.key).child("\(self.members[index])").setValue(self.balances[index])
                }
                
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    @IBAction func paidOffTo(_ sender: Any) {
        if (Int(amount.text!) == nil) {
            alertUser(title: "Not a valid amount", message: "Please fill in an valid amount")
            return
        } else {
            amountInt = Int(amount.text!)!
        }
        performSegue(withIdentifier: "PaymentToView", sender: self)
    }
    
    func alertUser(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PaymentToView" {
            let paymentToViewController = segue.destination as! PaymentToViewController
            paymentToViewController.members = self.members
            paymentToViewController.balances = self.balances
            paymentToViewController.groupname = self.groupname
            paymentToViewController.fromMember = self.member
            paymentToViewController.amount = self.amountInt
        }
    }
}
