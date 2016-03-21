//
//  ReportCell.swift
//  laudry app
//
//  Created by Michalina Simik on 3/7/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import UIKit


// read report class and create history reports to show in historyTableView

class ReportCell: UITableViewCell {
    
    @IBOutlet weak var tableCellTitle: UILabel!
    @IBOutlet weak var tableCellSubtitle: UILabel!
    @IBOutlet weak var tableCellImage: UIImageView!
    
    
    var report: Report! {
        didSet {
            loadCell()
        }
    }
    
    var resReport: Reservation! {
        didSet {
            loadCellWithReservation()
        }
    }

    
    func loadCell() {
//        let image = UIImage(named: "noun_161138_cc")
        if let filePath = NSBundle.mainBundle().pathForResource("noun_161138_cc", ofType: "png"), image = UIImage(contentsOfFile: filePath) {
            tableCellImage.contentMode = .ScaleAspectFit
            tableCellImage.image = image
        }

        if report.machineType == .Washer {
            tableCellTitle.text! = "Washing mashine # \(report.machineId)"
        
        } else {
            tableCellTitle.text! = "Dryer # \(report.machineId)"
        }
            tableCellImage.backgroundColor = UIColor(red: 45/255, green: 188/255, blue: 80/255, alpha: 1)
            tableCellSubtitle.text! = "Finished: \(dateFormat(report.timeFinished))"
    }

    
    func loadCellWithReservation() {
        tableCellTitle.text! = "Washing mashine # \(resReport.machineId)"
        if resReport.cancel {
            tableCellSubtitle.text! = "Reservation cancelled"
            tableCellImage.backgroundColor = UIColor(red: 1, green: 102/255, blue: 105/255, alpha:1)
            let image = UIImage(named: "noun_161132_cc")
            tableCellImage.contentMode = .ScaleAspectFit
            tableCellImage.image = image
        } else {
            tableCellSubtitle.text! = "Reservation: \(dateFormat(resReport.reservedTime))"
            tableCellImage.backgroundColor = UIColor(red: 1, green: 204/255, blue: 102/255, alpha: 1)
            let image = UIImage(named: "noun_161138_cc")
            tableCellImage.contentMode = .ScaleAspectFit
            tableCellImage.image = image
        }
     }
    
    
    func dateFormat(date: NSDate) -> String {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "dd-MM-YYYY HH:mm"
        return dateFormat.stringFromDate(date)
    }
    
    
}