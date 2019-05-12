//
//  NewsTableViewCell.swift
//  Shield For Dementia Carer
//
//  Created by 彭孝诚 on 2019/5/10.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsPubDateLabel: UILabel!
    @IBOutlet weak var newsDescLabel: UILabel!
    @IBOutlet weak var newsImageLabel: UIImageView!
    var newsItem: News?{
        didSet{
            newsTitleLabel.text = newsItem?.title
            newsPubDateLabel.text = newsItem?.pubDate
            newsDescLabel.text = newsItem?.description
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    

}
