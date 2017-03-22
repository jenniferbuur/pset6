//
//  PaymentToViewController.swift
//  jenniferbuur_pset6
//
//  Created by Jennifer Buur on 19-03-17.
//  Copyright © 2017 Jennifer Buur. All rights reserved.
//

import UIKit
import Firebase

class PaymentToViewController: UITableViewController {

    var ref: FIRDatabaseReference!
    var handle: FIRAuthStateDidChangeListenerHandle?
    var user = FIRAuth.auth()?.currentUser
    var fromMember = Int()
    var members = [String]()
    var balances = [Int]()
    var groupname = String()
    var amount = Int()
    var row = Int()
    var key = String()
    
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
    
    //MARK: tableviewdatasource
    // making tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count - 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "paymentCell") as! PaymentToTableViewCell
        if indexPath.row != fromMember {
            newCell.memberName.text = members[indexPath.row]
        }
        return newCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = user else { return }
        row = indexPath.row
        ref.child(user.uid).child("groups").observe(.value, with: {snapshot in
            for child in snapshot.children {
                let snapshotValue = (child as! FIRDataSnapshot).value as? NSDictionary
                if snapshotValue?["name"] as! String == self.groupname {
                    self.key = (child as! FIRDataSnapshot).key
                }
            }
            
        })
        balances[row] = balances[row] - amount
        ref.child(user.uid).child("groups").child(key).child(members[row]).setValue(balances[row])
        balances[fromMember] = balances[fromMember] + amount
        ref.child(user.uid).child("groups").child(key).child(members[fromMember]).setValue(balances[fromMember])
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
