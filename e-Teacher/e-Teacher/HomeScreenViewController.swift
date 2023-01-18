//
//  HomeScreenViewController.swift
//  e-Teacher
//
//  Created by Lyubomir on 7.01.23.
//

import UIKit

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {

    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        customizeBackground()
        helloLabel.text = "Здравейте, \(Model.adminData?.name ?? "")!"
        self.navigationItem.backAction?.title = "Изход"
        getStudents()
        NotificationCenter.default.addObserver(self, selector: #selector(getStudents), name: NSNotification.Name("ReloadStudents"), object: nil)
    }
    
    @objc func getStudents() {
        DataAPIManager.getStudents { result in
            switch result {
            case .success(let students):
                Model.students = students
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func changeStudentPassowrd(for idn: String) {
        let alert = UIAlertController(title: "Смяна на парола", message: "Въведете нова парола", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Нова парола"
            textField.addTarget(alert, action: #selector(alert.limitMinTFCount), for: [.editingDidBegin, .editingChanged])
        }
        alert.addAction(UIAlertAction(title: "Отказ", style: .cancel))
        alert.addAction(UIAlertAction(title: "Смяна", style: .default, handler: { _ in
            let newPassword = alert.textFields?[0].text ?? ""
            DataAPIManager.changePass(idn: idn, newPass: newPassword)
        }))
        alert.actions[1].accessibilityIdentifier = "Change"
        self.present(alert, animated: true, completion: nil)
    }
    
    private func getStudentMarks(idn: String) {
        DataAPIManager.getSemOc(idn: idn) { result in
            switch result {
            case .success(let disciplinesNMarks):
                Model.studentDisciplinesNMarks = disciplinesNMarks
                DispatchQueue.main.async {
                    let studiedDiciplinesVC = Utils.mainStoryboard.instantiateViewController(withIdentifier: "studiedDiciplines") as? StudiedDisciplinesCollectionViewController
                    self.navigationController?.pushViewController(studiedDiciplinesVC!, animated: true)
                }
                
            case.failure(let error):
                Utils.singleActionAlert(controller: self, title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    private func addCertification() {
        DataAPIManager.getSemOc(idn: Model.lastChosenStudentID) { _ in }
        DataAPIManager.fetchCertifiedSemesters(id: Model.lastChosenStudentID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    let certSemesVC = Utils.mainStoryboard.instantiateViewController(withIdentifier: "certifiedSemestersTVC") as? CertifiedSemsetersTableViewController
                    self.navigationController?.pushViewController(certSemesVC!, animated: true)
                case .failure(let error):
                    Utils.singleActionAlert(controller: self, title: "Error", message: error.localizedDescription)
                }
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openStudentDetails" {
            guard let detailsVC = segue.destination as? StudentDetailsViewController else { return }
            detailsVC.student = sender as? Student
        }
    }
    
    func customizeBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 0.5).cgColor, #colorLiteral(red: 0.4639953971, green: 0.480914712, blue: 0.5765916705, alpha: 0.5).cgColor]
        gradientLayer.shouldRasterize = true
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    //MARK: TableView Methods
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Model.students.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell") else { return UITableViewCell()}
        
        cell.textLabel?.text = Model.students[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Model.lastChosenStudentID = Model.students[indexPath.row].idn
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: "Редактиране на дисциплини", style: .default) { _ in
            self.getStudentMarks(idn: Model.students[indexPath.row].idn)
        }

        let secondAction: UIAlertAction = UIAlertAction(title: "Смяна на парола", style: .default) { _ in
            self.changeStudentPassowrd(for: Model.students[indexPath.row].idn)
        }
        
        let thirdAdction: UIAlertAction = UIAlertAction(title: "Добавяне на заверка", style: .default) { _ in
            self.addCertification()
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Отказ", style: .cancel) { action -> Void in }

        // add actions
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(thirdAdction)
        actionSheetController.addAction(cancelAction)
        present(actionSheetController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "openStudentDetails", sender: Model.students[indexPath.row])
    }

    
}
