//
//  ViewController.swift
//  SampleSlimyCollectionView
//
//  Created by Hiroto on 2017/09/24.
//  Copyright © 2017年 hi-ro-to. All rights reserved.
//

import UIKit
import SlimyCollectionView

class ViewController: SlimyCollectionViewController {
    private var page = 1
    private let limit = 10
    
    override func viewDidLoad() {
        // configure for slimy collection view before viewDidLoad
        defaultPhotoUrl = DemoPhotoUrlList.defaultDemoUrl
        slimyDelegate = self
        diffToLoadNext = 1
        reuseIdentifier = "slimyCell"
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func loadPhotos(isFirst: Bool) {
        var (start, end) = ((page - 1) * limit, limit * page)
        
        guard DemoPhotoUrlList.urlList.count >= start else { return }
        
        if DemoPhotoUrlList.urlList.count < end {
            end = DemoPhotoUrlList.urlList.count
        }
        
        let range = start..<end
        DemoPhotoUrlList.urlList[range].forEach { urlStr in
            guard let url = URL(string: urlStr) else { return }
            
            photoUrlList.append(url)
        }
        
        if isFirst {
            collectionView.reloadData()
        } else {
            let indexPaths = (range).map { return IndexPath(row: $0, section: 0) }
            
            insertItems(at: indexPaths)
        }
        
        page += 1
    }
    
}

extension ViewController: SlimyCollectionViewControllerDelegate {
    
    func firstLoad() {
        loadPhotos(isFirst: true)
    }
    
    func nextLoad() {
        loadPhotos(isFirst: false)
    }
    
}
