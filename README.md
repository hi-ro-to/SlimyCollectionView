# SlimyCollectionView
SlimyCollectionView is a UICollectionView library which is improved the performance to scroll images smoothly.

# Example Usage

```
// subclass custom UIViewController
class ViewController: SlimyCollectionViewController {
    override func viewDidLoad() {
        // configure for slimy collection view before viewDidLoad
        defaultPhotoUrl = "https://xxxxxxxxxxxxx.jp"
        slimyDelegate = self
        
        // what indexPath.item 
        diffToLoadNext = 1
        reuseIdentifier = "slimyCell"
        
        super.viewDidLoad()
    }
}

// MARK: - SlimyCollectionViewControllerDelegate

extension ViewController: SlimyCollectionViewControllerDelegate {
    
    func firstLoad() {
        // you can load first contents here.
    }
    
    func nextLoad() {
        // you can implement load-more function here.
    }
    
}
```

# Installation
## CocoaPods
Add to `Podfile`:

```
pod 'SlimyCollectionView'
```

# Requirements
SlimyCollectionView requires Swift 4.0.

# What I did

## 1. Cache image

Using image cache instead of connecting to network and downloading image is faster.
I use SDWebImage.
Standing on the shoulders of giants.

## 2. Prefetch (Only iOS 10 or above)

Image on UICollectionViewCell will be downloaded in advance of actually creating the cell if you use `UICollectionViewDataSourcePrefetching`.

I used 

`func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {`

※ Downloaded image will be often shown on wrong cell because UICollectionViewCell is reused.
So, I used `Operation` so that I can cancel the download when cell are off the screen.

## 3. Use `Int` for cell size

`Int` is easier for the system to calculate UICollectionViewCell size.

## 4. Reuse objects

Initialization is slow, especially of UIView.
We should avoid initializing.

Like this.

```
if imageView == nil {
    // initialize imageView
}
```

## 5. Avoid heavy drawing processing

Avoiding unnecessary drawing will provide load reduction to operation system.

Example, hiding vertical/horizantol scroll indicator.

```
collectionView.showsVerticalScrollIndicator = false
collectionView.showsHorizontalScrollIndicator = false
```

Remove 'contentView' from UICollectionViewCell.
Reduction of number of subviews will provide load reduction to operation system.

```
class SlimyCell: UICollectionViewCell {    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.removeFromSuperview()
    }
}
```

Set `opaque` to `true`.
Apple says the reason.

```
If set to YES, the drawing system treats the view as fully opaque, which allows the drawing system to optimize some drawing operations and improve performance. If set to NO, the drawing system composites the view normally with other content. The default value of this property is YES.
```

## 6. Refresh only when not in refresh

We don't have to reload data every time you pull to refresh.

```
if refreshControl.isRefreshing {
   refreshControl.endRefreshing()
}
```

## 7. Make sure to refresh new layout

We should make sure to correctly refresh the collection view layout when transitioning to a different Size Class or rotating the device.

```
super.viewWillTransition(to: size, with: coordinator)
coordinator.animate(alongsideTransition: { [weak self] context in
   guard let strongSelf = self else { return }
   strongSelf.collectionView?.collectionViewLayout.invalidateLayout()
}, completion: nil)
```

## 8. Use fixed size for cell

Avoid using Self-Sizing Cells if you don't need to change size of cell.

```
override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    return layoutAttributes
}
```

## 9. Add feed in animation for better user interface

Example:

```
UIView.animate(withDuration: 0.3) {
    self.imageView?.alpha = 1
}
```

## Other Tips

There are other things you can do to improve UICollectionView performance. (SlimyCollectionView does not support them.)

- Cache the size of cells if they aren’t always the same.
- Draw images or buttons or view components in `drawRect`
- Use the correct collection type
  - Arrays
    - Ordered collections. Access to their contents by index.the order matters.
    - [Apple Document](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Collections/Articles/Arrays.html#//apple_ref/doc/uid/20000132-BBCCJBIF)
  - Dictionaries
    - Unordered collections. Pairs of keys and values. access to their contents by keyed-value.
    - fast insertion and deletion operations
    - [Apple Document](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Collections/Articles/Dictionaries.html#//apple_ref/doc/uid/20000134-CJBCBGII)
  - Sets
    - Unordered collections. fast insertion and deletion operations. Quickly lookup.
    - [Apple Document](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Collections/Articles/Sets.html#//apple_ref/doc/uid/20000136-CJBDHAJD)
- We should use colorWithPatternImage for pattern Images
  - We should go with UIColor’s `colorWithPatternImage` when we show a patterned image which will be repeated or tiled to fill the background.
  - It’s faster to draw and won’t use a lot of memory in this case.

# License
MIT
