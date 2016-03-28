//
//  SectionData.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/7/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

class SectionData: NSObject {
    
    var subTitle:String = ""
    var title:String = ""
    var icon:String = ""
    var standByIcon:String = ""
    
    init(dictionary:[String : AnyObject]) {
        super.init()
        self.setValuesForKeysWithDictionary(dictionary)
    }
    
}
