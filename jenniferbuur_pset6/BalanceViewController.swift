//
//  BalanceViewController.swift
//  jenniferbuur_pset6
//
//  Created by Jennifer Buur on 19-03-17.
//  Copyright © 2017 Jennifer Buur. All rights reserved.
//

import UIKit
import Firebase

class BalanceViewController: UITableViewController {

    var ref: FIRDatabaseReference!
    var handle: FIRAuthStateDidChangeListenerHandle?
    var user = FIRAuth.auth()?.currentUser
    var members = [String]()
    var balances = [Int]()
    var groupname = String()
    var row = Int()
    
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
            self.searchAll()
            
            if user == nil {
                self.alertUser(title: "Something went wrong", message: "Please try again")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let handle = handle else { return }
        
        FIRAuth.auth()?.removeStateDidChangeListener(handle)
    }
    
    func searchAll() {
        guard let user = user else { return }
        
        ref.child(user.uid).child("groups").observe(.value, with: {snapshot in
            for child in snapshot.children {
                let snapshotValue = (child as! FIRDataSnapshot).value as! NSDictionary
                if snapshotValue["name"] as? String == self.groupname {
                    let count = (snapshotValue.count - 1)/2
                    for i in 0..<count {
                        self.members.append((snapshotValue["\(i)"] as? String)!)
                        self.balances.append((snapshotValue["\(self.members[i])"] as? Int)!)
                    }
                }
            }
        })
    }
    
    func alertUser(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        return
    }
    
    //MARK: tableviewdatasource
    // making tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "balanceCell") as! BalanceTableViewCell
        newCell.memberName.text = members[indexPath.row]
        newCell.balanceMember.text = String(balances[indexPath.row])
        return newCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        row = indexPath.row
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let paymentViewController = segue.destination as! PaymentViewController
        paymentViewController.member = tableView.indexPathForSelectedRow!.row
        paymentViewController.members = self.members
        paymentViewController.balances = self.balances
        paymentViewController.groupname = self.groupname
    }
}
