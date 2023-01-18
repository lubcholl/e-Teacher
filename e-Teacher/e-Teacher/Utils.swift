//
//  Utils.swift
//  e-Teacher
//
//  Created by Lyubomir on 7.01.23.
//

import Foundation
import UIKit

class Utils {
    static let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    
    static func singleActionAlert(controller: UIViewController, title: String, message: String, shouldDismiss: Bool = false) {
        
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            if shouldDismiss {
                controller.dismiss(animated: true)
            }
        }
        dialogMessage.addAction(ok)
        controller.present(dialogMessage, animated: true, completion: nil)
        
    }
    
    static func updateMarks(sender: UIViewController) {
        guard !Model.lastChosenStudentID.isEmpty else { return }
        DataAPIManager.getSemOc(idn: Model.lastChosenStudentID) { result in
            switch result {
            case .failure(let error):
                Utils.singleActionAlert(controller: sender, title: "Грешка", message: error.localizedDescription)
            case .success(_):
                DispatchQueue.main.async {
                    sender.dismiss(animated: true)
                }
            }
        }
    }
    
    static func uncertifiedSemesters() -> [String] {
        var alreadyCertified: [Int] = []
        var availableSemesters: [Int] = []
        
        for semes in Model.certifiedSemesters {
            guard let semesNumber = Int(String(semes.sem.last ?? ".")) else { continue }
            alreadyCertified.append(semesNumber)
        }
        
        for discipline in Model.studentDisciplinesNMarks {
            guard let semes = discipline.semes, !availableSemesters.contains(semes) else { continue }
            availableSemesters.append(semes)
        }
        var notCertified = availableSemesters.filter{ !alreadyCertified.contains($0) }
        
        notCertified = notCertified.sorted(by: <)
        
        var output: [String] = []
        
        for semes in notCertified {
            output.append(String(semes))
        }
        return output
    }
    
}

extension UIViewController {
    public func addSwipeBackGesture() {
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(dismissView))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
     }
    
    @objc func dismissView() {
        dismiss(animated: true)
        _ = navigationController?.popViewController(animated: true)
    }
}


extension UIAlertController {
    
    @objc func limitMinTFCount() {
        if let okAction = actions.first(where: { $0.accessibilityIdentifier == "Change" }) { 
            guard let textField = textFields?.first else { return }
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            okAction.isEnabled = text.count > 4
        }
    }
}
