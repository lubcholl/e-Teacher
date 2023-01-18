//
//  AddDisciplineTableViewController.swift
//  e-Teacher
//
//  Created by Lyubomir on 12.01.23.
//

import UIKit

class AddDisciplineTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var disciplineNameTextField: UITextField!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var teacherTextField: UITextField!
    @IBOutlet weak var planTextField: UITextField!
    @IBOutlet weak var protocolTextField: UITextField!
    @IBOutlet weak var semesterTextField: UITextField!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    private let marks = ["Без", "2.0", "3.0", "4.0", "5.0", "6.0"]
    private var initalMark = ""
    private var markData = MarkData()
    var idn = "" //student id
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idn = Model.lastChosenStudentID
    }

    
    @IBAction func changeMarkAction(_ sender: UIButton) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 200)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(marks.firstIndex(of: markLabel.text ?? "Без") ?? 0, inComponent: 0, animated: true)
        vc.view.addSubview(pickerView)
        let pickEventAlert = UIAlertController(title: "Оценка", message: "", preferredStyle: UIAlertController.Style.alert)
        pickEventAlert.setValue(vc, forKey: "contentViewController")
        let doneAction = UIAlertAction(title: "Готово" , style: .default, handler: { (action) -> Void in
            
            if self.initalMark != self.marks[pickerView.selectedRow(inComponent: 0)] {
                self.addButton.isEnabled = true
            } else {
                self.addButton.isEnabled = false
            }
            
            switch pickerView.selectedRow(inComponent: 0) {
            case 0:
                self.markLabel.text = "Без"
            case 1:
                self.markLabel.text = "2.0"
            case 2:
                self.markLabel.text = "3.0"
            case 3:
                self.markLabel.text = "4.0"
            case 4:
                self.markLabel.text = "5.0"
            case 5:
                self.markLabel.text = "6.0"
            default:
                break
            }
            
        })
        pickEventAlert.addAction(doneAction)
        self.present(pickEventAlert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        markData.idn = idn
        markData.discname = disciplineNameTextField.text ?? ""
        markData.oc = Double(markLabel.text!) ?? 0.0
        markData.titul = teacherTextField.text ?? ""
        markData.nplan = planTextField.text ?? ""
        markData.protnumb = protocolTextField.text ?? ""
        markData.semes = Int(semesterTextField.text ?? "") ?? 0
        DataAPIManager.addMark(markData: markData) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    Utils.updateMarks(sender: self)
                case .failure(let error):
                    Utils.singleActionAlert(controller: self, title: "Грешка", message: "Възникна проблем при добавянето на дисциплина! \(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: Picker Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        marks.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return marks[row]
    }
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 5
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 5
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
