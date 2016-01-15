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
    
    func invalidateLayoutwith(newCellWidth:CGFloat,newCellHeight:CGFloat,newCellGap:CGFloat) {
        cellWidth = newCellWidth
        cellHeight = newCellHeight
        cellGap = newCellGap
        attributeArray.removeAll()
        invalidateLayout()
    }
    
    override func prepareLayout() {
        if attributeArray.isEmpty {
            let itemCount:Int = (collectionView?.numberOfItemsInSection(sectionNumber))!
            for index in 0 ..< itemCount {
                let attribute = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: index, inSection: sectionNumber))
                attribute.size = CGSizeMake(cellWidth, cellHeight)
                let pointX:CGFloat = cellGap + cellWidth / 2 + CGFloat(index) * (cellWidth + cellGap)
                attribute.center = CGPointMake(pointX, CELL_NORMAL_HEIGHT - cellHeight / 2)
                attributeArray.append(attribute)
            }
        }
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSizeMake((cellWidth + cellGap) * CGFloat(attributeArray.count) + cellGap, cellHeight)
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return attributeArray[indexPath.item]
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attribute in attributeArray {
            if CGRectIntersectsRect(attribute.frame, rect ) {
                layoutAttributes.append(attribute)
            }
        }
        return layoutAttributes
    }

}
