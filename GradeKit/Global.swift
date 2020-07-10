//
//  Global.swift
//  GradeKit
//
//  Created by Pranav Ramesh on 7/9/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import Foundation

var gradeSheets: [GradeSheet] = []

class GradeSheet {
    var grades: [Grade]!
    var sheetName: String!
    
    /// Create empty gradesheet
    init() {
        self.grades = []
        self.sheetName = String()
    }
    
    /// Create existing gradesheet
    init(sheetName: String, grades: [Grade]) {
        self.sheetName = sheetName
        self.grades = grades
    }
    
    /// Get grade at index
    func grade(at index: Int) -> Grade {
        return grades[index]
    }
    
    // Delete grade
    func delete(at index: Int) {
        self.grades.remove(at: index)
    }
}

class Grade {
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
