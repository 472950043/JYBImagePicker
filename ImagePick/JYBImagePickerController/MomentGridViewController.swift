//
//  MomentGridViewController.swift
//  ImagePick
//
//  Created by yjs001 on 2018/8/13.
//  Copyright © 2018年 jyb. All rights reserved.
//

import UIKit
import Photos
import PhotosUI 

private let reuseIdentifier = String(describing: AlbumGridCell.self)

class MomentGridViewController: UITableViewController {
    
    let width = (UIScreen.main.bounds.size.width - 3) / 4
    
    var moments: PHFetchResult<PHAssetCollection>!
//    var counts: Array<Int>!
    var fetchMomentResults = [FetchResult]()
    
    fileprivate var itemSize: CGSize!
    fileprivate var thumbnailSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "时刻"
        moments = PHAssetCollection.fetchMoments(with: nil)
        self.setupMomentResults()
        self.tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
  
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func setupMomentResults() {
        fetchMomentResults.removeAll()
        for i in 0..<moments.count {
            let fetchResult = FetchResult()
            fetchResult.assetCollection = moments.object(at: i)
            fetchResult.fetchResult = PHAsset.fetchAssets(in: fetchResult.assetCollection, options: nil)
            fetchMomentResults.append(fetchResult)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        itemSize = CGSize(width: width, height: width)
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: width * scale, height: width * scale)
        
        navigationController?.isToolbarHidden = true
        
        tableView.scrollToRow(at: IndexPath(row: 0, section: fetchMomentResults.count - 1), at: .top, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isScrollBottom = false
    }

    var isScrollBottom = true
    
    // MARK: - Table view data source
    
    // MARK: Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchMomentResults.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isScrollBottom { //只在初始化的时候执行
            let popTime = DispatchTime.now() + 0.005 //延迟执行5毫秒
            DispatchQueue.main.asyncAfter(deadline: popTime) {
                tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: false)
            }
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 
        return fetchMomentResults[section].assetCollection.localizedTitle == nil ? 44 : 70
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let collection = fetchMomentResults[section].assetCollection,
            let fetchResult = fetchMomentResults[section].fetchResult {
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: collection.localizedTitle == nil ? 44 : 70))
            view.backgroundColor = UIColor.white
            let 标题 = UILabel(frame: CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 10, height: 44))
            标题.font = UIFont.boldSystemFont(ofSize: 16)
            标题.textColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
            view.addSubview(标题)
            if let creationDate = fetchResult.object(at: fetchResult.count - 1).creationDate {
                if collection.localizedTitle == nil {
                    标题.text = dateFormat(creationDate)
                } else {
                    标题.text = collection.localizedTitle
                    let 内容 = UILabel(frame: CGRect(x: 10, y: 34, width: UIScreen.main.bounds.width - 10, height: 26))
                    内容.text = dateFormat(creationDate) + ""
                    内容.font = UIFont.systemFont(ofSize: 16)
                    内容.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
                    view.addSubview(内容)
                }
            }
            return view
        }
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat((fetchMomentResults[indexPath.section].fetchResult.count - 1) / 4 + 1) * (width + 1)
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? AlbumGridCell {
//            let cell = AlbumGridCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
            cell.selectionStyle = .none
            cell.viewController = self
            cell.assetCollection = fetchMomentResults[indexPath.section].assetCollection
            cell.fetchResult = fetchMomentResults[indexPath.section].fetchResult
            cell.itemSize = itemSize
            cell.thumbnailSize = thumbnailSize
            cell.collectionView.reloadData()
            return cell
        }
        return UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
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
    
    
    func dateFormat(_ date: Date) -> String {
        //转化Date
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 8)
        //当前Date
        var dateNow = Date()
        dateNow = dateNow.addingTimeInterval(TimeInterval(NSTimeZone.system.secondsFromGMT()))
        dateFormatter.dateFormat = "yyyy"
        //今年零点Date
        if let dateYear = dateFormatter.date(from: dateFormatter.string(from: dateNow)) {
            if date.timeIntervalSince1970 < dateYear.timeIntervalSince1970 {//去年
                dateFormatter.dateFormat = "yyyy年MM月dd日"
                return dateFormatter.string(from: date)
            }
        }
        dateFormatter.dateFormat = "yyyy-MM"
        //本月零点Date
        if let dateMonth = dateFormatter.date(from: dateFormatter.string(from: dateNow)) {
            if date.timeIntervalSince1970 < dateMonth.timeIntervalSince1970 {//上个月
                dateFormatter.dateFormat = "MM月dd日"
                return dateFormatter.string(from: date)
            }
        }
        //今天零点Date
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let dateToday = dateFormatter.date(from: dateFormatter.string(from: dateNow)) {
            let ss = Int(dateToday.timeIntervalSince(date))
            if date.timeIntervalSince1970 > dateToday.timeIntervalSince1970 {
                dateFormatter.dateFormat = "今天(EEE)"
                return dateFormatter.string(from: date)
            } else {
                if ss < 2678400 {
                    let dd = ss / 86400 + 1
                    switch(dd) {
                    case 1:
                        dateFormatter.dateFormat = "昨天(EEE)"
                        return dateFormatter.string(from: date)
                    case 2:
                        dateFormatter.dateFormat = "前天(EEE)"
                        return dateFormatter.string(from: date)
                    default:
                        dateFormatter.dateFormat = "MM月dd日(EEE)"
                        return dateFormatter.string(from: date)
                    }
                }
            }
        }
        dateFormatter.dateFormat = "MM月dd日"
        return dateFormatter.string(from: date)
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension MomentGridViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Check each of the three top-level fetches for changes.
            
            if let changeDetails = changeInstance.changeDetails(for: moments) {
                // Update the cached fetch result.
                moments = changeDetails.fetchResultAfterChanges
                self.setupMomentResults()
                self.tableView.reloadData()
                // (The table row for this one doesn't need updating, it always says "All Photos".)
            }
            
        }
    }
}
