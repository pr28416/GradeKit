//
//  CumulativeCalcVC.swift
//  GradeKit
//
//  Created by Pranav Ramesh on 7/18/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

class CumulativeCalcVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gradeSheets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CumulativeCell", for: indexPath) as! CumulativeCell
        cell.name.text = gradeSheets[indexPath.row].sheetName
        cell.unweighted.text = String(format: "%.2f", GradeSheet.calculateGPA(sheet: gradeSheets[indexPath.row], weight: .unweighted) ?? 0.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateGPA()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updateGPA()
    }
    
    func updateGPA() {
        guard let indexPaths = tableView.indexPathsForSelectedRows else {
            unweightedLabel.text = "N/A"
            weightedLabel.text = "N/A"
            return
        }
        var avg = 0.0
        for i in indexPaths {
            avg += GradeSheet.calculateGPA(sheet: gradeSheets[i.row], weight: .unweighted) ?? 0.0
        }
        avg /= Double(indexPaths.count)
        unweightedLabel.text = String(format: "%.2f", avg)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backView.layer.masksToBounds = false
        backView.layer.cornerRadius = 10
        backView.layer.shadowColor = UIColor.black.cgColor
        backView.layer.shadowOpacity = 0.25
        backView.layer.shadowOffset = CGSize(width: 0, height: 8)
        backView.layer.shadowRadius = 6
        backView.layer.shadowPath = UIBezierPath(rect: backView.layer.bounds).cgPath
        backView.layer.masksToBounds = false
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.isEditing = true
        updateGPA()
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var unweightedLabel: UILabel!
    @IBOutlet weak var weightedLabel: UILabel!
    
}

class CumulativeCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var unweighted: UILabel!
    
}
