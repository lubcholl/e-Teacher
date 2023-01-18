//
//  AddStudentTableViewController.swift
//  e-Teacher
//
//  Created by Lyubomir on 17.01.23.
//

import UIKit

class AddStudentTableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
   
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var secondName: UITextField!
    @IBOutlet weak var familyName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var vtuEmail: UITextField!
    @IBOutlet weak var studyStatus: UITextField!
    @IBOutlet weak var course: UITextField!
    @IBOutlet weak var formOfStudy: UITextField!
    @IBOutlet weak var paymentType: UITextField!
    @IBOutlet weak var fn: UITextField!
    @IBOutlet weak var group: UITextField!
    @IBOutlet weak var PIN: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    private let taxOptions = ["Държавна такса обучение", "Платено обучение", "Освободен от такса"]
    var taxEdited = false
    private let studyFormOptions = ["Редовно", "Задочно", "Дистанционно"]
    var studyFormEdited = false
    private let studyStatusOptions = ["Учи", "Прекъснал", "Дипломиран"]
    var studyStatusEdited = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        setDelegates()
    }
    
    func setDelegates() {
        firstName.delegate = self
        secondName.delegate = self
        familyName.delegate = self
        email.delegate = self
        vtuEmail.delegate = self
        studyStatus.delegate = self
        course.delegate = self
        formOfStudy.delegate = self
        paymentType.delegate = self
        fn.delegate = self
        group.delegate = self
        PIN.delegate = self
    }
    
    
    @IBAction func cloaseButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        SaveStudent()
    }
    
    func SaveStudent() {
        let student = Student(idn: PIN.text!, firstname: firstName.text!, secondname: secondName.text!, lastname: familyName.text!, statusDescr: studyStatus.text!, formName: formOfStudy.text!, studyTypeName: paymentType.text!, email: email.text!, vtuemail: vtuEmail.text, fn: fn.text, name: nil, password: nil, specName: course.text!, fsiID: nil, group: Int(group.text!))
        
        
        DataAPIManager.addStudent(student: student) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let successful):
                    if successful {
                        NotificationCenter.default.post(name: NSNotification.Name("ReloadStudents"), object: nil)
                        Utils.singleActionAlert(controller: self, title: "Успех", message: "Студентът е добавен успешно!", shouldDismiss: true)
                    } else {
                        Utils.singleActionAlert(controller: self, title: "Грешка", message: "Студент със същото ЕГН вече съществува!")
                    }
                    
                case .failure(let error):
                    Utils.singleActionAlert(controller: self, title: "Грешка", message: error.localizedDescription)
                }
            }
        }
    }
    
    private var validFirstName = false, validSecndName = false, validFamilyName = false, validEmail = false, validVTUEmail = false, validStatus = false, validSpec = false, validFormOfStudy = false, validTaxType = false, validGroup = false, validFN = false, validPin = false
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == firstName {
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            validFirstName = text.count >= 2
        } else if textField == secondName {
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            validSecndName = text.count >= 2
        } else if textField == familyName {
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            validFamilyName = text.count >= 2
        } else if textField == email {
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            validEmail = validateEmail(candidate: text)
            tableView.footerView(forSection: 3)?.textLabel?.textColor = validEmail ? .gray : .red
            tableView.footerView(forSection: 3)?.textLabel?.text = validEmail ? "" : "e-mail-ът е невалиден"
        } else if textField == vtuEmail {
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            validVTUEmail = validateEmail(candidate: text)
            tableView.footerView(forSection: 4)?.textLabel?.textColor = validVTUEmail ? .gray : .red
            tableView.footerView(forSection: 4)?.textLabel?.text = validVTUEmail ? "" : "e-mail-ът е невалиден"
        } else if textField == studyStatus {
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            validStatus = text.count >= 2
        } else if textField == course {
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            validSpec = text.count >= 2
        } else if textField == formOfStudy {
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            validFormOfStudy = text.count >= 2
        } else if textField == paymentType {
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            validTaxType = text.count >= 2
        } else if textField == group {
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            validGroup = text.count >= 1
        } else if textField == fn {
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            validFN = text.count >= 8
        } else if textField == PIN {
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            validPin = text.count == 10
            tableView.footerView(forSection: 11)?.textLabel?.textColor = validPin ? .gray : .red
        }
        
        saveButton.isEnabled = validFirstName && validSecndName && validFamilyName && validEmail && validVTUEmail && validSpec && validGroup && validFN && validPin
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == paymentType {
            taxEdited = true
            let vc = UIViewController()
            vc.preferredContentSize = CGSize(width: 250,height: 200)
            let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
            pickerView.delegate = self
            pickerView.dataSource = self
            pickerView.selectRow(taxOptions.firstIndex(of: paymentType.text ?? "") ?? 0, inComponent: 0, animated: true)
            vc.view.addSubview(pickerView)
            let pickEventAlert = UIAlertController(title: "Вид такса", message: "", preferredStyle: UIAlertController.Style.alert)
            pickEventAlert.setValue(vc, forKey: "contentViewController")
            let doneAction = UIAlertAction(title: "Готово" , style: .default, handler: { (action) -> Void in
                self.taxEdited = false
                self.paymentType.text = self.taxOptions[pickerView.selectedRow(inComponent: 0)]
            })
            pickEventAlert.addAction(doneAction)
            self.present(pickEventAlert, animated: true, completion: nil)
            return false
        } else if textField == studyStatus {
            studyStatusEdited = true
            let vc = UIViewController()
            vc.preferredContentSize = CGSize(width: 250,height: 200)
            let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
            pickerView.delegate = self
            pickerView.dataSource = self
            pickerView.selectRow(studyStatusOptions.firstIndex(of: studyStatus.text ?? "") ?? 0, inComponent: 0, animated: true)
            vc.view.addSubview(pickerView)
            let pickEventAlert = UIAlertController(title: "Статус на студента", message: "", preferredStyle: UIAlertController.Style.alert)
            pickEventAlert.setValue(vc, forKey: "contentViewController")
            let doneAction = UIAlertAction(title: "Готово" , style: .default, handler: { (action) -> Void in
                self.studyStatusEdited = false
                self.studyStatus.text = self.studyStatusOptions[pickerView.selectedRow(inComponent: 0)]
            })
            pickEventAlert.addAction(doneAction)
            self.present(pickEventAlert, animated: true, completion: nil)
            return false
        } else if textField == formOfStudy {
            studyFormEdited = true
            let vc = UIViewController()
            vc.preferredContentSize = CGSize(width: 250,height: 200)
            let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
            pickerView.delegate = self
            pickerView.dataSource = self
            pickerView.selectRow(studyFormOptions.firstIndex(of: formOfStudy.text ?? "") ?? 0, inComponent: 0, animated: true)
            vc.view.addSubview(pickerView)
            let pickEventAlert = UIAlertController(title: "Форма на обучение", message: "", preferredStyle: UIAlertController.Style.alert)
            pickEventAlert.setValue(vc, forKey: "contentViewController")
            let doneAction = UIAlertAction(title: "Готово" , style: .default, handler: { (action) -> Void in
                self.studyFormEdited = false
                self.formOfStudy.text = self.studyFormOptions[pickerView.selectedRow(inComponent: 0)]
            })
            pickEventAlert.addAction(doneAction)
            self.present(pickEventAlert, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }

    
    //MARK: Picker data source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        taxOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if taxEdited {
            return taxOptions[row]
        } else if studyFormEdited {
            return studyFormOptions[row]
        } else if studyStatusEdited {
            return studyStatusOptions[row]
        }
        return "Internal error"
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
