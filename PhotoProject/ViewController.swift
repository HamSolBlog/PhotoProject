//
//  ViewController.swift
//  PhotoProject
//
//  Created by 김정운 on 2023/02/17.
//

import UIKit
import PhotosUI

class ViewController: UIViewController
{
    var fetchResults: PHFetchResult<PHAsset>?
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Photo Gallery App"
        
        self.makeNavigationItems()
        
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumInteritemSpacing = 0      // 사진 항목 끼리의 가로 간격
        layout.minimumLineSpacing = 1           // 사진 항목 끼리의 세로 간격
        
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 2 - 0.5, height: 200)  // 사진 크기
        
        collectionView.collectionViewLayout = layout
        
        collectionView.dataSource = self
    }
    
    func makeNavigationItems()
    {
        let rightItem = UIBarButtonItem(image: UIImage(systemName: "photo.on.rectangle"), style: .plain, target: self, action: #selector(checkPermission))
        rightItem.tintColor = .black
        self.navigationItem.rightBarButtonItem = rightItem

        let leftItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        leftItem.tintColor = .black
        self.navigationItem.leftBarButtonItem = leftItem
    
        let backColor = UINavigationBarAppearance()
        backColor.backgroundColor = .blue.withAlphaComponent(0.5)
        self.navigationItem.scrollEdgeAppearance = backColor
    }
    
    @objc func showGallery()
    {
        // 라이브러리의 객체화
        var openPhotoGallery = PHPickerConfiguration(photoLibrary: .shared())
        
        openPhotoGallery.selectionLimit = 10 // 사진의 선택 개수제한
        
        // 라이브러리의 ViewController 객체화
        let piker = PHPickerViewController(configuration: openPhotoGallery)
        piker.delegate = self
        self.present(piker, animated: true)
    }
    
    // View 새로고침
    @objc func refresh()
    {
        self.collectionView.reloadData()
    }
    
    @objc func checkPermission()
    {
        // 권한 설정
        switch PHPhotoLibrary.authorizationStatus()
        {
            case .authorized, .limited  : DispatchQueue.main.async
                {
                    self.showGallery()
                }
            case .denied                : DispatchQueue.main.async
                {
                    self.showAutorizationDeniedAlert()
                }
            case .notDetermined         : self.notDeterminedMesage()
            default : break
        }
    }
    
    func showAutorizationDeniedAlert()
    {
        let alert = UIAlertController(title: "포토라이브러리의 접근 권한을 활성화 해주세요", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel))
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default, handler:
        {
            action in
            guard let url = URL(string: UIApplication.openSettingsURLString) else {return}
            if UIApplication.shared.canOpenURL(url)
            {
                UIApplication.shared.open(url)
            }
        }))
        self.present(alert, animated: true)
    }
    
    func notDeterminedMesage()
    {
        PHPhotoLibrary.requestAuthorization
        {
            status in self.checkPermission()
        }
    }
}

extension ViewController:PHPickerViewControllerDelegate, UICollectionViewDataSource{
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult])
    {
        let identifiers = results.map{
            $0.assetIdentifier ?? ""
        }
        
        self.fetchResults = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        
        self.collectionView.reloadData()
        
        self.dismiss(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.fetchResults?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        if let asset = self.fetchResults?[indexPath.row]
        {
            cell.loadImage(asset: asset)
        }
        
        return cell
    }
}

