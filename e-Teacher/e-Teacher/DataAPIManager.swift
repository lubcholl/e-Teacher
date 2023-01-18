//
//  DataAPIManager.swift
//  e-Teacher
//
//  Created by Lyubomir on 7.01.23.
// eror 422 unprocessable entity

import Foundation
import UIKit


class DataAPIManager {
    
    static func getToken() {
        let url = URL(string: "http://localhost:5218/Token")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        let body = ["username": "lazarov", "password": "Lubcho1999@"]
        let bodyData = try? JSONSerialization.data(
           withJSONObject: body,
           options: .fragmentsAllowed
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                return
            } else if let data = data {
                print(String(data: data, encoding: .utf8)!)
                let token: String = try! JSONDecoder().decode(String.self, from: data)
                Model.token = token
            } else {
                print("error")
            }
        }
        task.resume()
    }
    
    
    static func logInAdmin(id: String, pass: String, completion: @escaping (Result<AdminData, Error>) -> Void) {
        let url = URL(string: "http://localhost:5218/api/AdminLogin?username=\(id)&password=\(pass)")
        guard let requestUrl = url, let token = Model.token else { return }
        var request = URLRequest(url: requestUrl)
        request.setValue("Bearer \(token)",forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                completion(.failure(error))
            } else if let data = data {
                guard !data.isEmpty else { return }
                let admin: AdminData = try! JSONDecoder().decode(AdminData.self, from: data)
                completion(.success(admin))
            } else {
                if let error = error {
                    print(error)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    static func getStudents(completion: @escaping (Result<[Student], Error>) -> Void) {
        let url = URL(string: "http://localhost:5218/api/GetStudents")
        guard let requestUrl = url, let token = Model.token else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.setValue("Bearer \(token)",forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                completion(.failure(error))
            } else if let data = data {
                guard !data.isEmpty else { return }
                let student: [Student] = try! JSONDecoder().decode([Student].self, from: data)
                completion(.success(student))
            } else {
                if let error = error {
                    print(error)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    static func getStudentPhoto(idn: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let url = URL(string: "http://localhost:5218/api/getphoto/\(idn)")
        guard let requestUrl = url, let token = Model.token else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.setValue("Bearer \(token)",forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                completion(.failure(error))
            } else if let data = data, let image = UIImage(data: data){
                completion(.success(image))
            } else {
                if let error = error {
                    print(error)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    static func getSemOc(idn: String, completion: @escaping (Result<[DisciplineAndMarks], Error>) -> Void) {
        let url = URL(string: "http://localhost:5218/api/Semoc?idn=\(idn)")
        guard let requestUrl = url, let token = Model.token else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.setValue("Bearer \(token)",forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                completion(.failure(error))
            } else if let data = data {
                var marks: [DisciplineAndMarks] = []
                if !data.isEmpty { marks = try! JSONDecoder().decode([DisciplineAndMarks].self, from: data) }
                Model.studentDisciplinesNMarks = marks
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("ReloadMarks"), object: nil)
                }

                completion(.success(marks))
            } else {
                if let error = error {
                    print(error)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    static func setMark(id: Int?, mark: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let token = Model.token, let id = id else { return }
        let url = URL(string: "http://localhost:5218/api/setoc")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        let body = ["ocid": id, "oc": mark]
        let bodyData = try? JSONSerialization.data(
           withJSONObject: body,
           options: .fragmentsAllowed
        )
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        request.setValue("application/json",forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                completion(.failure(error))
            } else if let _ = data {
                completion(.success(true))
            } else {
                if let error = error {
                    print(error)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    //idn, titul, semes, discname, oc are required
    
    static func addMark(markData: MarkData, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let token = Model.token else { return }
        let url = URL(string: "http://localhost:5218/api/semoc")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        let body = ["idn": markData.idn, "nplan": markData.nplan, "oc" : markData.oc, "titul" : markData.titul, "protnumb" : markData.protnumb, "discname" : markData.discname, "semes" : markData.semes, "ocid" : markData.ocid] as [String : Any]
        let bodyData = try? JSONSerialization.data(
           withJSONObject: body,
           options: .fragmentsAllowed
        )
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        request.setValue("application/json",forHTTPHeaderField: "Accept")
        request.httpMethod = "PUT"
        request.httpBody = bodyData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                completion(.failure(error))
            } else if let _ = data {
                completion(.success(true))
            } else {
                if let error = error {
                    print(error)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    static func deleteDiscipline(with id: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: "http://localhost:5218/api/semoc/?ocid=\(id)")
        guard let requestUrl = url, let token = Model.token else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.setValue("Bearer \(token)",forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                completion(.failure(error))
            } else if let _ = data {
                completion(.success(true))
            } else {
                if let error = error {
                    print(error)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    static func changePass(idn: String, newPass: String) {// Prepare URL
        guard let token = Model.token else { return }
        let url = URL(string: "http://localhost:5218/api/resetpassword")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        let body = ["idn": idn, "newpass": newPass]
        let bodyData = try? JSONSerialization.data(
           withJSONObject: body,
           options: .fragmentsAllowed
        )
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        request.setValue("application/json",forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                // Handle HTTP request error
                print(error)
                return
                
            } else if let data = data {
              print(String(data: data, encoding: .utf8)!)
            } else {
                print("error")
                // Handle unexpected error
            }
        }
        task.resume()
    }

    static func addStudent(student: Student, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let token = Model.token else { return }
        let url = URL(string: "http://localhost:5218/api/addstudent")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        let body = ["idn": student.idn, "firstname": student.firstname, "secondname" : student.secondname, "lastname" : student.lastname, "email" : student.email, "vtuemail" : student.vtuemail, "statusdescr" : student.statusDescr, "form_name" : student.formName, "StudyType_Name" : student.studyTypeName, "fn" : student.fn, "group" : student.group, "spec_name" : student.specName] as [String : Any]
        let bodyData = try? JSONSerialization.data(
           withJSONObject: body,
           options: .fragmentsAllowed
        )
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        request.setValue("application/json",forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                completion(.failure(error))
            } else if let _ = data, let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 400 {
                    completion(.success(false))
                } else if 200 ..< 300 ~= httpResponse.statusCode { return }
                
                completion(.success(true))
            } else {
                if let error = error {
                    print(error)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    static func fetchCertifiedSemesters(id: String, completion: @escaping (Result<[CertifiedSemester], Error>) -> Void) {
        let url = URL(string: "http://localhost:5218/api/Zs?idn=\(id)")
        guard let requestUrl = url, let token = Model.token else { fatalError() }

        var request = URLRequest(url: requestUrl)
        request.setValue("Bearer \(token)",forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                completion(.failure(error))
            } else if let data = data, let httpResponse = response as? HTTPURLResponse {
                guard 200 ..< 300 ~= httpResponse.statusCode else {
                    print("Status code was \(httpResponse.statusCode), but expected 2xx")
                    return
                }
                var certifiedSemesters: [CertifiedSemester] = []
                if httpResponse.statusCode != 204 {
                    certifiedSemesters = try! JSONDecoder().decode([CertifiedSemester].self, from: data)
                }
                Model.certifiedSemesters = certifiedSemesters
                completion(.success(certifiedSemesters))
            } else {
                if let error = error {
                    print(error)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    static func addSemesterCertification(id: String, semes: String, type: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let token = Model.token else { return }
        let url = URL(string: "http://localhost:5218/api/AddCertification")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        let body = ["idn": id, "type": type, "semester" : semes] as [String : String]
        let bodyData = try? JSONSerialization.data(
           withJSONObject: body,
           options: .fragmentsAllowed
        )
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        request.setValue("application/json",forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                completion(.failure(error))
            } else if let _ = data, let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 400 {
                    completion(.success(false))
                } else if 200 ..< 300 ~= httpResponse.statusCode { return }
                
                completion(.success(true))
            } else {
                if let error = error {
                    print(error)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
}

