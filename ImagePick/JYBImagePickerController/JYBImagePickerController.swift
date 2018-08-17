//
//  JYBImagePickerController.swift
//  ImagePick
//
//  Created by yjs001 on 2018/8/9.
//  Copyright © 2018年 jyb. All rights reserved.
//

import UIKit
import Photos

class JYBImagePickerController: UITableViewController {
    
    // MARK: Types for managing sections, cell and segue identifiers
    enum Section: Int {
//        case allPhotos = 0
        case moments = 0
        case smartAlbums
        case userCollections
        
        static let count = 3
    }
    
    
    fileprivate let imageManager = PHCachingImageManager()
    
    // MARK: Properties
//    var allPhotos: PHFetchResult<PHAsset>!
    let sectionLocalizedTitles = [nil, nil, "我的相簿"]
    
    var moments: PHFetchResult<PHAssetCollection>!
    var smartAlbums: PHFetchResult<PHAssetCollection>!
    var userCollections: PHFetchResult<PHCollection>!

    var fetchSmartResults = [FetchResult]()
    var fetchUserResults = [FetchResult]()
    // MARK: UIViewController / Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "照片"
//        self.navigationItem.title = "照片"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(取消))
        
        self.tableView.register(UINib(nibName: "AlbumCustomCell", bundle: nil), forCellReuseIdentifier: "AlbumCustomCell")
        
        // Create a PHFetchResult object for each section in the table view.
        //let allPhotosOptions = PHFetchOptions()
        //allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        //allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        moments = PHAssetCollection.fetchMoments(with: nil)
        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        self.setupSmartResults()
        self.setupUserResults()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func setupSmartResults() {
        fetchSmartResults.removeAll()
        for i in 0..<smartAlbums.count {
            let collection = smartAlbums.object(at: i)
            let assets = PHAsset.fetchAssets(in: collection, options: nil)
            if assets.count > 0 {
                // 过滤  && collection.assetCollectionSubtype == PHAssetCollectionSubtype.smartAlbumVideos
                //自拍 相机胶卷 慢动作 视频 个人收藏 连拍快照 屏幕快照 延时摄影 最近删除 最近添加 已隐藏 全景照片 人像 实况照片 长曝光 动图
                let fetchResult = FetchResult()
                fetchResult.assetCollection = collection
                fetchResult.fetchResult = assets
                fetchSmartResults.append(fetchResult)
            }
        }
    }
    
    func setupUserResults() {
        fetchUserResults.removeAll()
        for i in 0..<userCollections.count {
            let collection = userCollections.object(at: i)
            guard let assetCollection = collection as? PHAssetCollection
                else { fatalError("expected asset collection") }
            let assets = PHAsset.fetchAssets(in: assetCollection, options: nil)
            if assets.count > 0 {
                let fetchResult = FetchResult()
                fetchResult.assetCollection = assetCollection
                fetchResult.fetchResult = assets
                fetchUserResults.append(fetchResult)
            }
        }
    }
    
    func imagePickerError(_ message: String) {
        let alertController = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }

    @objc func 取消() {
        print("取消")
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    // MARK: Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .moments: return 1
        case .smartAlbums: return fetchSmartResults.count
        case .userCollections: return fetchUserResults.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch Section(rawValue: section)! {
        case .moments: return 0
        case .smartAlbums: return 0
        case .userCollections: return fetchUserResults.count == 0 ? 0 : 30
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionLocalizedTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch Section(rawValue: indexPath.section)! {
        case .moments: return moments.count == 0 ? 0 : 90
        case .smartAlbums: return fetchSmartResults.count == 0 ? 0 : 90
        case .userCollections: return fetchUserResults.count == 0 ? 0 : 90
        }
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCustomCell") as? AlbumCustomCell {
            switch Section(rawValue: indexPath.section)! {
            case .moments:
                cell.名称.text = "时刻"
                cell.数量.text = "\(moments.count)"
                if moments.count > 0 {
                    requestImage(cell, PHAsset.fetchAssets(in: moments.object(at: moments.count - 1), options: nil))
                }
            case .smartAlbums:
                cell.名称.text = fetchSmartResults[indexPath.row].assetCollection.localizedTitle
                cell.setupCell(fetchSmartResults[indexPath.row].fetchResult.count)
                requestImage(cell, fetchSmartResults[indexPath.row].fetchResult)
            case .userCollections:
                cell.名称.text = fetchUserResults[indexPath.row].assetCollection.localizedTitle
                cell.setupCell(fetchUserResults[indexPath.row].fetchResult.count)
                requestImage(cell, fetchUserResults[indexPath.row].fetchResult)
            }
            return cell
        }
        return UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //消除cell选择痕迹
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch Section(rawValue: indexPath.section)! {
        case .moments:
            let destination = MomentGridViewController(nibName: "MomentGridViewController", bundle: Bundle.main)
            self.navigationController?.pushViewController(destination, animated: true)
//            let destination = AlbumGridViewController(nibName: "AlbumGridViewController", bundle: Bundle.main)
//            destination.title = "时刻"
//            destination.moments = moments
//            self.navigationController?.pushViewController(destination, animated: true)
        case .smartAlbums:
            let destination = AssetGridViewController(nibName: "AssetGridViewController", bundle: Bundle.main)
            destination.title = fetchSmartResults[indexPath.row].assetCollection.localizedTitle
            destination.fetchResult = fetchSmartResults[indexPath.row].fetchResult
            self.navigationController?.pushViewController(destination, animated: true)
        case .userCollections:
            let destination = AssetGridViewController(nibName: "AssetGridViewController", bundle: Bundle.main)
            destination.title = fetchUserResults[indexPath.row].assetCollection.localizedTitle
            destination.fetchResult = fetchUserResults[indexPath.row].fetchResult
            self.navigationController?.pushViewController(destination, animated: true)
        }
        
    }
    
    func requestImage(_ cell: AlbumCustomCell, _ fetchResult: PHFetchResult<PHAsset>) {
        if fetchResult.count == 0 {
            return
        } else if fetchResult.count == 1 {
            requestImage(cell, contentSize: cell.image1.frame.size, asset: fetchResult.object(at: fetchResult.count - 1)) { (image) in
                cell.image1.image = image
            }
        } else if fetchResult.count == 2 {
            requestImage(cell, contentSize: cell.image1.frame.size, asset: fetchResult.object(at: fetchResult.count - 1)) { (image) in
                cell.image1.image = image
            }
            requestImage(cell, contentSize: cell.image2.frame.size, asset: fetchResult.object(at: fetchResult.count - 2)) { (image) in
                cell.image2.image = image
            }
        } else {
            requestImage(cell, contentSize: cell.image1.frame.size, asset: fetchResult.object(at: fetchResult.count - 1)) { (image) in
                cell.image1.image = image
            }
            requestImage(cell, contentSize: cell.image2.frame.size, asset: fetchResult.object(at: fetchResult.count - 2)) { (image) in
                cell.image2.image = image
            }
            requestImage(cell, contentSize: cell.image3.frame.size, asset: fetchResult.object(at: fetchResult.count - 3)) { (image) in
                cell.image3.image = image
            }
        }
    }
    
    func requestImage(_ cell: AlbumCustomCell, contentSize: CGSize, asset: PHAsset, _ block: ((_ image: UIImage?) -> Void)?) {
        let scale = UIScreen.main.scale
        let thumbnailSize = CGSize(width: contentSize.height * scale, height: contentSize.height * scale)
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                block?(image)
            }
        })
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}

// MARK: PHPhotoLibraryChangeObserver
extension JYBImagePickerController: PHPhotoLibraryChangeObserver {
  
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Check each of the three top-level fetches for changes.
            
            if let changeDetails = changeInstance.changeDetails(for: moments) {
                // Update the cached fetch result.
                moments = changeDetails.fetchResultAfterChanges
                tableView.reloadSections(IndexSet(integer: Section.moments.rawValue), with: .automatic)
                // (The table row for this one doesn't need updating, it always says "All Photos".)
            }
            
            // Update the cached fetch results, and reload the table sections to match.
            if let changeDetails = changeInstance.changeDetails(for: smartAlbums) {
                smartAlbums = changeDetails.fetchResultAfterChanges
                self.setupSmartResults()
                tableView.reloadSections(IndexSet(integer: Section.smartAlbums.rawValue), with: .automatic)
            }
            if let changeDetails = changeInstance.changeDetails(for: userCollections) {
                userCollections = changeDetails.fetchResultAfterChanges
                self.setupUserResults()
                tableView.reloadSections(IndexSet(integer: Section.userCollections.rawValue), with: .automatic)
            }
            
        }
    }
}

class FetchResult: NSObject {
    var assetCollection: PHAssetCollection!
    var fetchResult: PHFetchResult<PHAsset>!
}
