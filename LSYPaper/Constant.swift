//
//  Constant.swift
//  Paragram
//
//  Created by 梁树元 on 11/28/15.
//  Copyright © 2015 allsome.love. All rights reserved.
//

import UIKit

public let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
public let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
public let POSTER_HEIGHT_RATIO:CGFloat = 5 / 9
public let POSTER_HEIGHT = SCREEN_HEIGHT * POSTER_HEIGHT_RATIO
public let CELL_NORMAL_HEIGHT = SCREEN_HEIGHT - POSTER_HEIGHT
public let CORNER_REDIUS:CGFloat = 6
public let TINY_RATIO:CGFloat = 0.44
public let WINDOW:UIWindow = UIApplication.sharedApplication().keyWindow!
