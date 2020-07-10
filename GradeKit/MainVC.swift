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
        /// TODO: Make algorithm to find unweighted grade of classes in grade sheet
        cell.grade.text = "A+"
        cell.sheetName.text = gradeSheets[indexPath.row].sheetName
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

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
