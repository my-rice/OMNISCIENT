//
//  CameraList.swift
//  omniscient
//
//  Created by Antonio Langella on 24/04/22.
//

import Foundation
import UIKit

class CameraList: NSObject,UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTypeIdentifier", for: indexPath)
           
           // Configure the cell’s contents.
           //cell.textLabel!.text = "Cell text"
               
           return cell
    }
}
