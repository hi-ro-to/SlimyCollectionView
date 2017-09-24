//
//  SlimyCollectionViewController.swift
//  SlimyCollectionView
//
//  Created by Hiroto Ichinose on 2017/06/06.
//  Copyright © 2017年 HirotoIchinose. All rights reserved.
//

import UIKit

public protocol SlimyCollectionViewControllerDelegate {
    func firstLoad()
    func nextLoad()
//    func prepareForPrefetching(url: URL)
//    func cancelPrefetching(url: URL)
//    func execPrefetching(url: URL)
//    func showImageForImageView(_ imageView: UIImageView, photoUrl: URL)
}

open class SlimyCollectionViewController: UIViewController {
    fileprivate var refreshControl: UIRefreshControl!
    public var photoUrlList = [URL]()
    public var reuseIdentifier = "slimyCell"
    public var defaultPhotoUrl = ""
    public var slimyDelegate: SlimyCollectionViewControllerDelegate?
    public var diffToLoadNext = 1
    public var collectionView: UICollectionView!
    
    // prefetch queue
    fileprivate var imageLoadQueue: OperationQueue?
    fileprivate var imageLoadOperations: [IndexPath: ImageLoadOperation]?
    
    // use integer not for cell or subviews to do anti-aliasing
    fileprivate let cellWidth = Int(UIScreen.main.bounds.width / 2)

    open override func viewDidLoad() {
        super.viewDidLoad()

        // set collectionView
        let flowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: flowLayout)
        view.addSubview(collectionView)

        // refresh controll
        setupRefreshControl()

        // setup datasource and delegate
        collectionView.dataSource = self
        collectionView.delegate = self

        // setup collection view cell
        collectionView.register(SlimyCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        if #available(iOS 10.0, *) {
            collectionView?.prefetchDataSource = self
            imageLoadQueue = OperationQueue()
            imageLoadOperations = [IndexPath: ImageLoadOperation]()
        }

        // load first photo list
        slimyDelegate?.firstLoad()
    }
    
    public func insertItems(at indexPaths: [IndexPath]) {
        // update cells in main thread
        DispatchQueue.main.async {
            self.collectionView?.performBatchUpdates({ () -> Void in
                self.collectionView?.insertItems(at: indexPaths)
            }, completion: nil)
        }
    }
    
    fileprivate func getPhotoUrl(at indexPath: IndexPath) -> URL {
        var photoUrl: URL!
        if photoUrlList.count > indexPath.item {
            photoUrl = photoUrlList[indexPath.item]
        } else {
            photoUrl = URL(fileURLWithPath: defaultPhotoUrl)
        }
        return photoUrl
    }
}

// MARK: - UICollectionViewDataSource

extension SlimyCollectionViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoUrlList.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SlimyCell

        // Configure the cell
        let photoUrl = getPhotoUrl(at: indexPath)
        cell.configure(photoUrl: photoUrl)

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SlimyCollectionViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == photoUrlList.count - diffToLoadNext {
            slimyDelegate?.nextLoad()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let imageLoadOperation = imageLoadOperations?[indexPath] else {
            return
        }
        imageLoadOperation.cancel()
        _ = imageLoadOperations?.removeValue(forKey: indexPath)
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // We should make sure to correctly refresh the collection view layout when transitioning to a different Size Class or rotating the device.
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] context in

            guard let strongSelf = self else { return }
            strongSelf.collectionView?.collectionViewLayout.invalidateLayout()

            }, completion: nil)
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension SlimyCollectionViewController: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let _ = imageLoadOperations?[indexPath] {
                return
            }

            let photoUrl = getPhotoUrl(at: indexPath)
            let imageLoadOperation = ImageLoadOperation(photoUrl: photoUrl)
            imageLoadQueue?.addOperation(imageLoadOperation)
            imageLoadOperations?[indexPath] = imageLoadOperation
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard let imageLoadOperation = imageLoadOperations?[indexPath] else {
                return
            }
            imageLoadOperation.cancel()
            _ = imageLoadOperations?.removeValue(forKey: indexPath)
        }
    }
}

// MARK: - RefreshControll

extension SlimyCollectionViewController {
    fileprivate func setupRefreshControl() {
        collectionView?.alwaysBounceVertical = true
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refreshControl)
    }

    @objc fileprivate func refresh() {
        // Call when only refresh is needness.
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }

        if #available(iOS 10.0, *) {
            imageLoadOperations?.forEach { $1.cancel() }
        }

        photoUrlList.removeAll()
        collectionView?.reloadData()
    }
}

// MARK: - ImageLoadOperationDelegate
//extension SlimyCollectionViewController: ImageLoadOperationDelegate {
//    func cancelPrefetching(url: URL) {
//        slimyDelegate?.cancelPrefetching(url: url)
//    }
//
//    func execPrefetching(url: URL) {
//        slimyDelegate?.execPrefetching(url: url)
//    }
//}
//
//extension SlimyCollectionViewController: SlimyCellDelegate {
//    func showImageForImageView(_ imageView: UIImageView, photoUrl: URL) {
//        slimyDelegate?.showImageForImageView(imageView, photoUrl: photoUrl)
//    }
//}

