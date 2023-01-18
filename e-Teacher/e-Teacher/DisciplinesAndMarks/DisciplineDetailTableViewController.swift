//
//  DisciplineDetailTableViewController.swift
//  e-Student
//
//  Created by Lyubomir on 7.05.22.
//

import UIKit

class DisciplineDetailTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        marks.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return marks[row]
    }
    
  
    var discipline: DisciplineAndMarks?

    @IBOutlet weak var discNameLabel: UILabel!
    @IBOutlet weak var teacerLabel: UILabel!
    @IBOutlet weak var planNumberLabel: UILabel!
    @IBOutlet weak var protocolNumerLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var markLabel: UILabel!
    
    private let marks = ["Без", "2.0", "3.0", "4.0", "5.0", "6.0"]
    private var initalMark = ""
    private var markID: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        guard let discipline = discipline else { return }
        markID = discipline.ocid
        if discipline.mark == 0.0 {
            markLabel.text = "Без"
            initalMark = "Без"
        } else {
            markLabel.text = String(discipline.mark)
            initalMark = String(discipline.mark)
        }
        discNameLabel.text = discipline.discname
        teacerLabel.text = discipline.titul
        protocolNumerLabel.text = discipline.protnumb
        planNumberLabel.text = discipline.nplan
    }
    
    init?(coder: NSCoder, discipline: DisciplineAndMarks?) {
        self.discipline = discipline
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                self.saveButton.isEnabled = true
            } else {
                self.saveButton.isEnabled = false
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
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        var mark = 0
        switch markLabel.text {
        case "Бeз":
            mark = 0
        case "2.0":
            mark = 2
        case "3.0":
            mark = 3
        case "4.0":
            mark = 4
        case "5.0":
            mark = 5
        case "6.0":
            mark = 6
        default:
            break
        }
        
        DataAPIManager.setMark(id: markID, mark: mark) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let isSuccessful):
                    if isSuccessful {
                        Utils.updateMarks(sender: self)
                    }
                case .failure(let error):
                    Utils.singleActionAlert(controller: self, title: "Грешка", message: "Неуспешно запазване! \(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        let dialogMessage = UIAlertController(title: "Потвърждение", message: "Сигурни ли сте, че искате да изтриете тази дисциплина?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Откажи", style: .cancel)
        let delete = UIAlertAction(title: "Изтриване", style: .destructive) { _ in
            
            guard let id = self.markID else { return }
            DataAPIManager.deleteDiscipline(with: id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let isSuccessful):
                        if isSuccessful {
                            Utils.updateMarks(sender: self)
                        }
                    case .failure(let error):
                        Utils.singleActionAlert(controller: self, title: "Грешка", message: "Неуспешно изтриване! \(error.localizedDescription)")
                    }
                }
            }
            
        }
        dialogMessage.addAction(delete)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
