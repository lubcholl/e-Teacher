//
//  Types.swift
//  e-Teacher
//
//  Created by Lyubomir on 7.01.23.
//

import Foundation

struct Token: Codable {
    let token: String
    let tokenType: String
    let expiresIn: Int
    let username: String
    let issued: String
    let expires: String
    
    enum CodingKeys: String, CodingKey {
        case token = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case username = "userName"
        case issued = ".issued"
        case expires = ".expires"
    }
}

struct AdminData: Codable {
    let name: String
    let username: String
    let userID: Int
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case username = "username"
        case userID = "userid"
    }
}

struct Student: Codable {
    let idn, firstname, secondname, lastname, statusDescr, formName, studyTypeName: String
    let email, vtuemail, fn, name, password, specName: String?
    let fsiID, group: Int?

    enum CodingKeys: String, CodingKey {
        case idn, firstname, secondname, lastname, name, password, email, vtuemail, fn, group
        case fsiID = "fsi_id"
        case statusDescr = "statusdescr"
        case specName = "spec_name"
        case formName = "form_name"
        case studyTypeName = "StudyType_Name"
    }
}

struct DisciplineAndMarks: Codable, Equatable {
    let idn, nplan: String?
    let ndiscsemes: Int?
    let ndiscipl: String?
    let mark: Double
    let titul, protnumb: String?
    let linkedToOldOcid: Int?
    let discname: String?
    let semes: Int?
    let ocid: Int

    enum CodingKeys: String, CodingKey {
        case idn, nplan, ndiscsemes, ndiscipl, titul, protnumb
        case linkedToOldOcid = "linked_to_old_ocid"
        case discname
        case semes 
        case mark = "oc"
        case ocid
    }
    var sectionTitle: String {
        String(semes ?? 0)
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.semes == rhs.semes
    }
}

struct MarkData: Codable { //the data needed to add a mark
    var idn: String? = ""
    var nplan: String? = ""
    var ndiscsemes: Int? = 0
    var ndiscipl: String? = ""
    var oc: Double? = 0.0
    var titul: String?
    var protnumb: String?
    var linked_to_old_ocid: Int?
    var discname: String?
    var semes: Int?
    var ocid: Int? = 0
    
    init() {}
}

struct Section: Codable {
    let title: String
    let disciplines: [DisciplineAndMarks]
}

struct CertifiedSemester: Codable {
    let idn: String
    let sem: String
    let type, datezav: String
}
