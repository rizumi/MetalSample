//
//  DataSource.swift
//  MetalSample
//
//  Created by Ryo Izumi on 2018/07/22.
//  Copyright © 2018年 izm. All rights reserved.
//

import Foundation
import UIKit

struct Example {
    let title: String
    let storyboardName: String
    
    init(title: String, storyboardName: String){
        self.title = title
        self.storyboardName = storyboardName
    }
    
    var controller: UIViewController? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let viewController: UIViewController?
        
        viewController = storyboard.instantiateInitialViewController()
        viewController?.title = title
        return viewController
    }
}

struct DataSource {
    lazy var examples: [Example] = [Example(title: "Triangle",
                                            storyboardName: "Triangle"),
                                    Example(title: "Uniform",
                                            storyboardName: "Uniform"),
                                    Example(title: "FrameBufferObject",
                                            storyboardName: "FrameBufferObject")
                                   ]
}
