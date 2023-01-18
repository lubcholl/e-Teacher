//
//  AddCertifiedSemesterTableViewController.swift
//  e-Teacher
//
//  Created by Lyubomir on 17.01.23.
//

import UIKit

class AddCertifiedSemesterTableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var certificationType: UITextField!
    @IBOutlet weak var semes: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    private let typeOptions: [String] = ["Редовна", "Служебна"]
    private let semesOptions: [String] = Utils.uncertifiedSemesters()
    private var typeEdited = false
    private var semesEdited = false
    private var validType = false
    private var validSemes = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        certificationType.delegate = self
        semes.delegate = self
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        DataAPIManager.addSemesterCertification(id: Model.lastChosenStudentID, semes: semes.text!, type: certificationType.text!) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let successful):
                    if successful {
                        self.dismiss(animated: true)
                        DataAPIManager.fetchCertifiedSemesters(id: Model.lastChosenStudentID) { result in
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: NSNotification.Name("ReloadZS"), object: nil)
                                self.dismiss(animated: true)
                            }
                        }
                    }
                case .failure(let error):
                    Utils.singleActionAlert(controller: self, title: "Грешка", message: error.localizedDescription)
                }
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == certificationType {
            typeEdited = true
            validType = true
            let vc = UIViewController()
            vc.preferredContentSize = CGSize(width: 250,height: 200)
            let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
            pickerView.delegate = self
            pickerView.dataSource = self
            pickerView.selectRow(typeOptions.firstIndex(of: certificationType.text ?? "") ?? 0, inComponent: 0, animated: true)
            vc.view.addSubview(pickerView)
            let pickEventAlert = UIAlertController(title: "Вид заверка", message: "", preferredStyle: UIAlertController.Style.alert)
            pickEventAlert.setValue(vc, forKey: "contentViewController")
            let doneAction = UIAlertAction(title: "Готово" , style: .default, handler: { (action) -> Void in
                self.typeEdited = false
                self.certificationType.text = self.typeOptions[pickerView.selectedRow(inComponent: 0)]
                if self.validType && self.validSemes {
                    self.saveButton.isEnabled = true
                }
            })
            pickEventAlert.addAction(doneAction)
            self.present(pickEventAlert, animated: true, completion: nil)
            
            return false
        } else if textField == semes {
            semesEdited = true
            validSemes = true
            let vc = UIViewController()
            vc.preferredContentSize = CGSize(width: 250,height: 200)
            let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
            pickerView.delegate = self
            pickerView.dataSource = self
            pickerView.selectRow(semesOptions.firstIndex(of: semes.text ?? "") ?? 0, inComponent: 0, animated: true)
            vc.view.addSubview(pickerView)
            let pickEventAlert = UIAlertController(title: "Семестър", message: "", preferredStyle: UIAlertController.Style.alert)
            pickEventAlert.setValue(vc, forKey: "contentViewController")
            let doneAction = UIAlertAction(title: "Готово" , style: .default, handler: { (action) -> Void in
                self.semesEdited = false
                self.semes.text = self.semesOptions[pickerView.selectedRow(inComponent: 0)]
                if self.validType && self.validSemes {
                    self.saveButton.isEnabled = true
                }
            })
            pickEventAlert.addAction(doneAction)
            self.present(pickEventAlert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    
    // MARK: - Picker view data source

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if typeEdited {
            return typeOptions.count
        } else if semesEdited {
            return semesOptions.count
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if typeEdited {
            return typeOptions[row]
        } else if semesEdited {
            return semesOptions[row]
        }
        return "?"
    }
    
    
    //MARK: Table view
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
