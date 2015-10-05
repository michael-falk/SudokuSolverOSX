//
//  Controller.swift
//  SudokuSolverOSX
//
//  Created by Michael Falk on 10/2/15.
//  Copyright © 2015 MichaelFalk. All rights reserved.
//

import Cocoa

class Controller: NSObject {
  
  @IBOutlet weak var arrayController: NSArrayController!
  
  var cells: NSMutableArray = NSMutableArray()
  
  override func awakeFromNib() {
    
    for i in 1...9 {
      for j in 1...9 {
        let cell = SudokuCellObject(x: i, y: j)
        self.arrayController.addObject(cell)
        
      }
    }
  }

}
