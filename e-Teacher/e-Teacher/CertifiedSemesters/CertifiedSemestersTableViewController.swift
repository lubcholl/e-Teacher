//
//  certifiedSemsetersTableViewController.swift
//  e-Student
//
//  Created by Lyubomir on 8.05.22.
//

import UIKit

class CertifiedSemsetersTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeBackGesture()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadZS), name: NSNotification.Name("ReloadZS"), object: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        guard !Utils.uncertifiedSemesters().isEmpty else {
            Utils.singleActionAlert(controller: self, title: "Внимание", message: "Няма семестри, които да могат да бъдат заверени!")
            return
        }
        performSegue(withIdentifier: "addCertifiedSemester", sender: nil)
    }
    
    @objc func reloadZS() {
        tableView.reloadData()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Model.certifiedSemesters.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "certifiedSemesterCell", for: indexPath) as! certifiedSemesterTableViewCell
        cell.mainLabel.text = "Семестър \(Model.certifiedSemesters[indexPath.row].sem)"
        cell.descriptionLabel.text = Model.certifiedSemesters[indexPath.row].type
        cell.detailLabel.text = String(Model.certifiedSemesters[indexPath.row].datezav.prefix(10))
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Change the selected background view of the cell.
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
