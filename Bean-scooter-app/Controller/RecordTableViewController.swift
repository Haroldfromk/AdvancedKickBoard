//
//  RecordTableViewController.swift
//  Bean-scooter-app
//
//  Created by Dongik Song on 4/26/24.
//

import UIKit

class RecordTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 150
        tableView.register(UINib(nibName: "RecordTableViewCell", bundle: nil), forCellReuseIdentifier: "recordCell")

        self.navigationController?.isNavigationBarHidden = false

    }



}

extension RecordTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        RecordSingleton.shared.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as? RecordTableViewCell else {
            return UITableViewCell() }
        
        let item = RecordSingleton.shared.array[indexPath.row]
        cell.configure(cellModel: item)
        
        return cell
    }

    
}
