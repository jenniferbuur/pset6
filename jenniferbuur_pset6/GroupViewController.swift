//
//  ViewController.swift
//  jenniferbuur_pset6
//
//  Created by Jennifer Buur on 17-03-17.
//  Copyright © 2017 Jennifer Buur. All rights reserved.
//

import UIKit
import Firebase

class GroupViewController: UITableViewController {
    
    var ref: FIRDatabaseReference!
    var groups = [String]()
    var row = Int()
    var handle: FIRAuthStateDidChangeListenerHandle?
    var user = FIRAuth.auth()?.currentUser
    var key = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        searchAll()
        tableView.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
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
            self.groups.removeAll()
            
            for child in snapshot.children {
                let snapshotValue = (child as! FIRDataSnapshot).value as? NSDictionary
                self.groups.append((snapshotValue?["name"] as? String)!)
            }
            
            self.tableView.reloadData()
        })
    }
    
    //MARK: tableviewdatasource
    // making tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as! GroupTableViewCell
        newCell.groupName.text = groups[indexPath.row]
        return newCell
    }
    
    // editing tableview
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            guard let user = user else { return }
            ref.child(user.uid).child("groups").observe(.value, with: {snapshot in
                for child in snapshot.children {
                    let snapshotValue = child as? NSDictionary
                    if snapshotValue?["name"] as! String == self.groups[indexPath.row] {
                        self.key = (child as! FIRDataSnapshot).key
                        self.ref.child(user.uid).child("groups").child(self.key).setValue(nil)
                    }
                }

            })
            searchAll()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        row = indexPath.row
        performSegue(withIdentifier: "BalanceView", sender: self)
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
        if segue.identifier == "BalanceView" {
            let balanceViewController = segue.destination as! BalanceViewController
            balanceViewController.groupname = self.groups[row]
        }
    }
}

