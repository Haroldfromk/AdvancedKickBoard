//
//  RecordTableViewCell.swift
//  Bean-scooter-app
//
//  Created by Dongik Song on 4/26/24.
//

import UIKit

class RecordTableViewCell: UITableViewCell {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
      
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        distanceLabel.text = ""
        priceLabel.text = ""
        dateLabel.text = ""
    }
    
    func configure(cellModel: RecordModel) {
        
        let time =  cellModel.time
        let distance = cellModel.distance
        let price = Int(Double(distance) * 1.8)
        
        distanceLabel.text = " \(distance) m"
        dateLabel.text = " \(time)"
        priceLabel.text = " \(price)원"
    }
    
}
