//
//  PhotoCell.swift
//  PhotoProject
//
//  Created by 김정운 on 2023/02/19.
//

import UIKit
import PhotosUI

class PhotoCell: UICollectionViewCell {
    
    func loadImage(asset: PHAsset)
    {
        let imageManeger = PHImageManager()
        let scale = UIScreen.main.scale
        let imageSize = CGSize(width: 150 * scale, height: 150 * scale)
            
        imageManeger.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: nil)
        {
            image, info in
            self.photoImageView.image = image
        }
    }
    
    @IBOutlet weak var photoImageView: UIImageView!
    {
        didSet
        {
            photoImageView.contentMode = .scaleAspectFill
        }
    }
}
