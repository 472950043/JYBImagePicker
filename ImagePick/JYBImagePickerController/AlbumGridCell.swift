//
//  AlbumGridCell.swift
//  ImagePick
//
//  Created by yjs001 on 2018/8/13.
//  Copyright © 2018年 jyb. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

class AlbumGridCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    let reuseGridIdentifier = String(describing: PhotoCustomCell.self)
    
    var viewController: UIViewController!
    
    @IBOutlet var collectionView: UICollectionView!
    
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    
    fileprivate let imageManager = PHCachingImageManager()
    
    var itemSize: CGSize!
    var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: reuseGridIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseGridIdentifier)
        
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        // If we get here without a segue, it's because we're visible at app launch,
        // so match the behavior of segue from the default "All Photos" view.
        if assetCollection != nil && fetchResult == nil {
            fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    //定义每个UICollectionView 的大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult.object(at: indexPath.item)
        
        // Dequeue a GridViewCell.
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseGridIdentifier, for: indexPath) as? PhotoCustomCell
            else { fatalError("unexpected cell in collection view") }
        
        // Add a badge to the cell if the PHAsset represents a Live Photo.
        if asset.mediaSubtypes.contains(.photoLive) {
            cell.livePhotoBadgeImage = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        }
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destination = AssetViewController(nibName: "AssetViewController", bundle: Bundle.main)
        destination.asset = fetchResult.object(at: indexPath.item)
        destination.assetCollection = assetCollection
        viewController.navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: UIScrollView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // MARK: Asset Caching
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard viewController.isViewLoaded && viewController.view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > self.collectionView.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension AlbumGridCell: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                // If we have incremental diffs, animate them in the collection view.
                guard let collectionView = self.collectionView else { fatalError() }
                collectionView.performBatchUpdates({
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, reload, move
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, changed.count > 0 {
                        collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                // Reload the collection view if incremental diffs are not available.
                collectionView!.reloadData()
            }
            resetCachedAssets()
        }
    }
}
