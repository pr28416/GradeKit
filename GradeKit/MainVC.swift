//
//  ViewController.swift
//  GradeKit
//
//  Created by Pranav Ramesh on 7/9/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit

class MainVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gradeSheets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCell", for: indexPath) as! MainCell
        cell.grade.text = String(format: "%.2f", GradeSheet.calculateGPA(sheet: gradeSheets[indexPath.row], weight: .unweighted) ?? 0.0)
        cell.sheetName.text = gradeSheets[indexPath.row].sheetName
        
        cell.layer.cornerRadius = 10
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.25
        cell.layer.shadowOffset = CGSize(width: 0, height: 8)
        cell.layer.shadowRadius = 6
        cell.layer.shadowPath = UIBezierPath(rect: cell.layer.bounds).cgPath
        cell.layer.masksToBounds = false
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "editGradeSheet", sender: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            
            let edit = UIAction(title: "Edit") { _ in
                self.performSegue(withIdentifier: "editGradeSheet", sender: indexPath.row)
            }
            edit.image = UIImage(systemName: "square.and.pencil")
            
            let delete = UIAction(title: "Delete") { _ in
                let alert = UIAlertController(title: "Confirm deletion", message: "Are you sure you want to delete this grade sheet? This action is irreversible.", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    gradeSheets.remove(at: indexPath.row)
                    uploadData()
                    self.collectionView.deleteItems(at: [indexPath])
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            delete.image = UIImage(systemName: "trash")
            delete.attributes = .destructive
            
            return UIMenu(title: "Options", image: nil, identifier: nil, options: .displayInline, children: [edit, delete])
        }
    }
    
    @IBAction func unwind(for segue: UIStoryboardSegue, sender: Any?) {
//        DispatchQueue.global(qos: .userInitiated).async {
//                DispatchQueue.main.async {
        self.collectionView.reloadData()
//                }
//            }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editGradeSheet" {
            let VC = (segue.destination as! UINavigationController).topViewController as! GradeSheetVC
            VC.gradeSheet = gradeSheets[sender as! Int]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let inset: CGFloat = 16
            flowLayout.minimumLineSpacing = inset
            flowLayout.minimumInteritemSpacing = inset
            flowLayout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
            flowLayout.itemSize = CGSize(width: (collectionView.bounds.width - 3 * inset) / 2, height: 128)
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if downloadData() {
            collectionView.reloadData()
        }
    }

    @IBAction func add(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "addGradeSheet", sender: nil)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func debugReload(_ sender: Any) {
        self.collectionView.reloadData()
    }
}

class MainCell: UICollectionViewCell {
    @IBOutlet weak var grade: UILabel!
    @IBOutlet weak var sheetName: UILabel!
    
}
