//
//  StudentDetailsViewController.swift
//  e-Teacher
//
//  Created by Lyubomir on 8.01.23.
//

import UIKit

class StudentDetailsViewController: UIViewController {

    
    @IBOutlet weak var studentPhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var formOfStudyLabel: UILabel!
    @IBOutlet weak var facultyNumberLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    
    var student: Student?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage()
        setLabels()
    }
    
    func setImage() {
        studentPhoto.layer.borderWidth = 1
        studentPhoto.layer.masksToBounds = false
        studentPhoto.layer.borderColor = UIColor.black.cgColor
        studentPhoto.layer.cornerRadius = studentPhoto.frame.height/2
        studentPhoto.clipsToBounds = true
        studentPhoto.contentMode = .scaleAspectFill
        
        guard let studentID = student?.idn else { return }
//        studentPhoto.layer.cornerRadius = 50
        DataAPIManager.getStudentPhoto(idn: studentID) { result in
            switch result {
            case .success(let photo):
                DispatchQueue.main.async {
                    self.studentPhoto.image = photo
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func setLabels() {
        nameLabel.text = student?.name
        courseNameLabel.text = student?.specName
        emailLabel.text = student?.email?.isEmpty ?? true ? "Няма" : student?.email
        formOfStudyLabel.text = student?.formName
        facultyNumberLabel.text = student?.fn
        
        statusLabel.text = student?.statusDescr
        
        if let group = student?.group {
            groupLabel.text = String(group)
        } else {
            groupLabel.text = "Не е зададена"
        }
        taxLabel.text = student?.studyTypeName
    }
    

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    

}
