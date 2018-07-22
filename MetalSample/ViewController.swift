//
//  ViewController.swift
//  MetalSample
//
//  Created by Ryo Izumi on 2018/07/22.
//  Copyright © 2018年 izm. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var dataSource = DataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let sample = dataSource.examples[indexPath.row]
        cell.textLabel?.text = sample.title
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.examples.count;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sample = dataSource.examples[indexPath.row]
        if let controller = sample.controller {
            navigationController?.pushViewController(controller, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

