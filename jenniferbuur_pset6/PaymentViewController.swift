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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    @IBAction func addToBalance(_ sender: Any) {
        if (Int(amount.text!) == nil) {
            alertUser(title: "Not a valid amount", message: "Please fill in an valid amount")
            return
        } else {
            amountInt = Int(amount.text!)!
            for index in 0..<balances.count {
                if index != member {
                    balances[index] = balances[index] - amountInt/balances.count
                } else {
                    balances[index] = balances[index] + amountInt - amountInt/balances.count
                }
                self.ref.child((user?.uid)!).child(groupname).child(members[index]).setValue(balances[index])
            }
        }
    }
    
    @IBAction func paidOffTo(_ sender: Any) {
        if (Int(amount.text!) == nil) {
            alertUser(title: "Not a valid amount", message: "Please fill in an valid amount")
            return
        } else {
            amountInt = Int(amount.text!)!
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let paymentToViewController = navigationController.viewControllers.first! as! PaymentToViewController
        paymentToViewController.fromMember = self.member
        paymentToViewController.amount = self.amountInt
    }
}
