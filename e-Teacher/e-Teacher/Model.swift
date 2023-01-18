//
//  Model.swift
//  e-Teacher
//
//  Created by Lyubomir on 7.01.23.
//

import Foundation

class Model {
    static var token: String?
    static var adminData: AdminData?
    static var students: [Student] = []
    static var studentDisciplinesNMarks: [DisciplineAndMarks] = []
    static var lastChosenStudentID = ""
    static var certifiedSemesters: [CertifiedSemester] = []
}
