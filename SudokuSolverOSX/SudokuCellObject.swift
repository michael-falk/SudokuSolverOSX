//
//  SudokuCellObject.swift
//  SudokuSolverOSX
//
//  Created by Michael Falk on 10/2/15.
//  Copyright © 2015 MichaelFalk. All rights reserved.
//

import Cocoa

class SudokuCellObject: NSObject {
  
  var x: Int
  var y: Int
  var value: Int?
  
  internal init(x: Int, y: Int) {
    self.x = x
    self.y = y
    self.value = nil
  }
  
}
