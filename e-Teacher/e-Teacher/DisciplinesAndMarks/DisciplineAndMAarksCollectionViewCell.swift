//
//  DisciplineAndMAarksCollectionViewCell.swift
//  e-Teacher
//
//  Created by Lyubomir on 8.01.23.
//

import UIKit

class DisciplineAndMAarksCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var diciplineLabel: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    
    
    @IBOutlet weak var teacherLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(with discipline: DisciplineAndMarks) {
        if discipline.mark == 0.0 {
            markLabel.text = "-"
        } else {
            markLabel.text = String(discipline.mark)
        }
        
        diciplineLabel.text = discipline.discname
        teacherLabel.text = discipline.titul
    }

}
