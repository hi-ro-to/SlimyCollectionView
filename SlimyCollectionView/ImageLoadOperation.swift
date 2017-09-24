//
//  ImageLoadOperation.swift
//  SlimyCollectionView
//
//  Created by Hiroto Ichinose on 2017/06/08.
//  Copyright © 2017年 hi-ro-to. All rights reserved.
//

import Foundation
import SDWebImage

class ImageLoadOperation: Operation {
    private var photoUrl: URL
    private var imagePrefetcher: SDWebImagePrefetcher?
    
    init(photoUrl: URL) {
        self.photoUrl = photoUrl
        imagePrefetcher = SDWebImagePrefetcher()
    }
    
    override func cancel() {
        imagePrefetcher?.cancelPrefetching()

        super.cancel()
    }

    override func main() {
        if isCancelled {
            return
        }
        
        imagePrefetcher?.prefetchURLs([photoUrl], progress: nil)
    }
}
