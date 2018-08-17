//
//  AlbumCustomCell.swift
//  ImagePick
//
//  Created by yjs001 on 2018/8/9.
//  Copyright © 2018年 jyb. All rights reserved.
//

import UIKit

class AlbumCustomCell: UITableViewCell {
    
    @IBOutlet var image1: UIImageView!
    @IBOutlet var image2: UIImageView!
    @IBOutlet var image3: UIImageView!
    @IBOutlet var 名称: UILabel!
    @IBOutlet var 数量: UILabel!
    
    var representedAssetIdentifier: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(_ count: Int) {
        if count == 0 {
            image1.isHidden = true
            image2.isHidden = true
            image3.isHidden = true
        } else if count == 1 {
            image1.isHidden = false
            image2.isHidden = true
            image3.isHidden = true
        } else if count == 2 {
            image1.isHidden = false
            image2.isHidden = false
            image3.isHidden = true
        } else {
            image1.isHidden = false
            image2.isHidden = false
            image3.isHidden = false
        }
        数量.text = "\(count)"
    }
    
}
