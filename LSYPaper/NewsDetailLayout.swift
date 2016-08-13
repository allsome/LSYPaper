//
//  NewsDetailLayout.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/9/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

// A deprecated horizontal layout

private let sectionNumber = 0
class NewsDetailLayout: UICollectionViewLayout {

    private var attributeArray:[UICollectionViewLayoutAttributes] = []
    private var cellWidth:CGFloat = 0
    private var cellHeight:CGFloat = 0
    private var cellGap:CGFloat = 0
    
    init(cellWidth:CGFloat,cellHeight:CGFloat,cellGap:CGFloat) {
        super.init()
        self.cellWidth = cellWidth
        self.cellHeight = cellHeight
        self.cellGap = cellGap
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
    
    func invalidateLayoutwith(_ newCellWidth:CGFloat,newCellHeight:CGFloat,newCellGap:CGFloat) {
        cellWidth = newCellWidth
        cellHeight = newCellHeight
        cellGap = newCellGap
        attributeArray.removeAll()
        invalidateLayout()
    }
    
    override func prepare() {
        if attributeArray.isEmpty {
            let itemCount:Int = (collectionView?.numberOfItems(inSection: sectionNumber))!
            for index in 0 ..< itemCount {
                let attribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: sectionNumber))
                attribute.size = CGSize(width: cellWidth, height: cellHeight)
                let pointX:CGFloat = cellGap + cellWidth / 2 + CGFloat(index) * (cellWidth + cellGap)
                attribute.center = CGPoint(x: pointX, y: CELL_NORMAL_HEIGHT - cellHeight / 2)
                attributeArray.append(attribute)
            }
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: (cellWidth + cellGap) * CGFloat(attributeArray.count) + cellGap, height: cellHeight)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributeArray[(indexPath as NSIndexPath).item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attribute in attributeArray {
            if attribute.frame.intersects(rect ) {
                layoutAttributes.append(attribute)
            }
        }
        return layoutAttributes
    }

}
