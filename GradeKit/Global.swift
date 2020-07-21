//
//  Global.swift
//  GradeKit
//
//  Created by Pranav Ramesh on 7/9/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import Foundation

protocol GradePersistance {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}

var gradeSheets: [GradeSheet] = []

var options: [String:Any] = [
    "Unweighted GPA Scale": 4.0
]

enum GradeWeight {
    case unweighted, weighted
}

func downloadData() -> Bool {
    let userDefaults = UserDefaults.standard
    print("Attempting download of data...")
    do {
        try gradeSheets = userDefaults.getObject(forKey: "gradeSheets", castTo: [GradeSheet].self)
        print("Success in downloading data")
        return true
    } catch {
        print(error.localizedDescription)
        return false
    }
}

func uploadData() -> Bool {
    print("Attempting upload of data...")
    let userDefaults = UserDefaults.standard
    do {
        try userDefaults.setObject(gradeSheets, forKey: "gradeSheets")
        print("Success in uploading data")
        return true
    } catch {
        print(error.localizedDescription)
        return false
    }
}

class GradeSheet: Codable {
    var grades: [Grade]!
    var sheetName: String!
    var id: String?
    
    static let unweightedScale = [
        "A+": 4.0,
        "A": 4.0,
        "A-": 3.67,
        "B+": 3.33,
        "B": 3.0,
        "B-": 2.67,
        "C+": 2.33,
        "C": 2.0,
        "C-": 1.67,
        "D+": 1.33,
        "D": 1.0,
        "D-": 0.67,
        "F": 0.0
    ]
    
    /// Calculate unweighted GPA
    static func calculateGPA(sheet: GradeSheet, weight: GradeWeight) -> Double? {
        switch weight {
        case .unweighted:
            var avg: Double = 0
            for grade in sheet.grades {
                if options["Unweighted GPA Scale"] as! Double == 5.0 {
                    avg += grade.letter == "F" ? 0 : 1 + unweightedScale[grade.letter]!
                } else {
                    avg += unweightedScale[grade.letter]!
                }
                
            }
            avg /= Double(sheet.grades.count)
            return avg
        case .weighted:
            // TODO: Add weighted GPA functionality
            return nil
        }
    }
    
    /// Create empty gradesheet
    init() {
        self.grades = []
        self.sheetName = String()
    }
    
    /// Create existing gradesheet
    init(sheetName: String, grades: [Grade], id: String) {
        self.sheetName = sheetName
        self.grades = grades
        self.id = id
    }
    
    /// Get grade at index
    func grade(at index: Int) -> Grade {
        return grades[index]
    }
    
    /// Delete grade
    func delete(at index: Int) {
        self.grades.remove(at: index)
        uploadData()
    }
    
    /// Generate ID
    func generateID() {
        if id == nil {
            id = UUID().uuidString
        } else {
            print("ID already exists")
        }
    }
}

extension UserDefaults: GradePersistance {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object : Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object : Decodable {
        guard let data = data(forKey: forKey) else {throw ObjectSavableError.noValue}
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}

class Grade: Codable {
    var letter = String()
    var className = String()
    var type = "Standard"
    var credits = Double()
    
    /// Create existing grade
    init(className: String, type: String, credits: Double, letterGrade: String) {
        self.className = className
        self.type = type
        self.credits = credits
        self.letter = letterGrade
    }
    
    /// Create new grade
    init() {
        self.className = ""
        self.type = "Standard"
        self.credits = 0
        self.letter = "A+"
    }
    
    var description: String {
        return "Class: \(className), Type: \(type), Credits: \(credits), Grade: \(letter)"
    }
    
}
