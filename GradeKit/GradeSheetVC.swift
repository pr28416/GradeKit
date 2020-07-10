//
//  GradeSheetVC.swift
//  GradeKit
//
//  Created by Pranav Ramesh on 7/9/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

class GradeSheetVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return letterGrades.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: letterGrades[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let indexPath = tableView.indexPath(for: pickerView.superview?.superview?.superview as! GradeSheetCell)!
        gradeSheet.grade(at: indexPath.row).letter = letterGrades[row]
    }
    
    @IBAction func typeSet(_ sender: UISegmentedControl) {
        let indexPath = tableView.indexPath(for: sender.superview?.superview?.superview as! GradeSheetCell)!
        gradeSheet.grade(at: indexPath.row).type = sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "Standard"
    }
    
    @IBAction func creditSet(_ sender: UIStepper) {
        let cell = sender.superview?.superview?.superview as! GradeSheetCell
        let indexPath = tableView.indexPath(for: cell)!
        gradeSheet.grade(at: indexPath.row).credits = sender.value / 2
        cell.creditLabel.text = "\(gradeSheet.grade(at: indexPath.row).credits)"
    }
    
    @IBAction func classFieldChanged(_ sender: UITextField) {
        let indexPath = tableView.indexPath(for: sender.superview?.superview?.superview as! GradeSheetCell)!
        gradeSheet.grade(at: indexPath.row).className = sender.text ?? ""
    }
    
    var gradeSheet = GradeSheet()
    var typeConversion = [
        "Standard": 0,
        "Honors": 1,
        "AP/IB": 2
    ]
    var letterGrades = ["A+", "A", "A-", "B+", "B", "B-", "C+", "C", "C-", "D+", "D", "D-", "F"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gradeSheet.grades.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gradeCell", for: indexPath) as! GradeSheetCell
        cell.classNameField.text = gradeSheet.grade(at: indexPath.row).className
        cell.typeField.selectedSegmentIndex = typeConversion[gradeSheet.grade(at: indexPath.row).type] ?? 0
        cell.creditStepper.value = gradeSheet.grade(at: indexPath.row).credits * 2
        cell.creditLabel.text = "\(gradeSheet.grade(at: indexPath.row).credits)"
        cell.gradePicker.delegate = self
        cell.gradePicker.dataSource = self
        cell.gradePicker.selectRow(letterGrades.firstIndex(of: gradeSheet.grade(at: indexPath.row).letter) ?? 0, inComponent: 0, animated: false)
        
        cell.backView.layer.cornerRadius = 10
        cell.backView.layer.shadowColor = UIColor.black.cgColor
        cell.backView.layer.shadowOffset = CGSize(width: 0, height: 2.5)
        cell.backView.layer.shadowRadius = 3
        cell.backView.layer.shadowOpacity = 0.3
        cell.backView.layer.shadowPath = UIBezierPath(roundedRect: cell.backView.bounds, cornerRadius: 10).cgPath
        
        cell.gradePicker.layer.cornerRadius = 10
        
        cell.cellNumber.text = "\(indexPath.row+1)"
        cell.cellNumber.layer.cornerRadius = 12
        cell.cellNumber.layer.masksToBounds = true

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            gradeSheet.delete(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            tableView.reloadData()
        }
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        let alert = UIAlertController(title: "Finish Grade Sheet", message: "Enter the sheet name below.", preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = "Enter sheet name"
            tf.text = self.gradeSheet.sheetName
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Finish", style: .default, handler: { _ in
            guard let tf = alert.textFields?[0], let tx = tf.text, !tx.isEmpty else {
                let errorAlert = UIAlertController(title: "Invalid sheet name", message: "Sheet name was empty. Please enter a sheet name.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Go back", style: .cancel, handler: { (_) in
                    self.present(alert, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
                return
            }
            self.gradeSheet.sheetName = tx
            gradeSheets.append(self.gradeSheet)
            for i in self.gradeSheet.grades {
                print(i.description)
            }
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func add(_ sender: Any) {
        gradeSheet.grades.append(Grade())
        tableView.insertRows(at: [IndexPath(row: gradeSheet.grades.count-1, section: 0)], with: .left)
    }
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        if editButton.title == "Edit" {
            editButton.title = "Done"
        } else {
            editButton.title = "Edit"
        }
        tableView.setEditing(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gradeSheet.grades.append(Grade())
        self.isModalInPresentation = true
    }
    
    @IBOutlet weak var tableView: UITableView!
}

class GradeSheetCell: UITableViewCell {
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var creditStepper: UIStepper!
    @IBOutlet weak var typeField: UISegmentedControl!
    @IBOutlet weak var classNameField: UITextField!
    @IBOutlet weak var gradePicker: UIPickerView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var cellNumber: UILabel!
}
