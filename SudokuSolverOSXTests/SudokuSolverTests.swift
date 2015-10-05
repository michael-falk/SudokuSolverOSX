//
//  SudokuSolverTests.swift
//  SudokuSolverTests
//
//  Created by Michael Falk on 7/8/15.
//  Copyright (c) 2015 MichaelFalk. All rights reserved.
//

import Cocoa
import XCTest
import SudokuSolverOSX

class SudokuSolverTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testSudokuSolvable() {
    let unaryConstraints: [UnaryConstraint<Index, Int>] = [
      GoodValueConstraint(variable: Index(1,2), goodValue: 3),
      GoodValueConstraint(variable: Index(1,3), goodValue: 8),
      GoodValueConstraint(variable: Index(2,1), goodValue: 9),
      GoodValueConstraint(variable: Index(2,4), goodValue: 6),
      GoodValueConstraint(variable: Index(3,2), goodValue: 2),
      GoodValueConstraint(variable: Index(3,5), goodValue: 1),
      GoodValueConstraint(variable: Index(3,7), goodValue: 6),
      GoodValueConstraint(variable: Index(4,3), goodValue: 2),
      GoodValueConstraint(variable: Index(4,6), goodValue: 1),
      GoodValueConstraint(variable: Index(4,9), goodValue: 6),
      GoodValueConstraint(variable: Index(5,3), goodValue: 5),
      GoodValueConstraint(variable: Index(5,4), goodValue: 4),
      GoodValueConstraint(variable: Index(5,6), goodValue: 7),
      GoodValueConstraint(variable: Index(5,7), goodValue: 2),
      GoodValueConstraint(variable: Index(6,1), goodValue: 8),
      GoodValueConstraint(variable: Index(6,4), goodValue: 9),
      GoodValueConstraint(variable: Index(6,7), goodValue: 5),
      GoodValueConstraint(variable: Index(7,3), goodValue: 3),
      GoodValueConstraint(variable: Index(7,5), goodValue: 7),
      GoodValueConstraint(variable: Index(7,8), goodValue: 9),
      GoodValueConstraint(variable: Index(8,6), goodValue: 2),
      GoodValueConstraint(variable: Index(8,9), goodValue: 5),
      GoodValueConstraint(variable: Index(9,7), goodValue: 4),
      GoodValueConstraint(variable: Index(9,8), goodValue: 7)]
    
    let sudoku = SudokuSolver(unaryConstraints: unaryConstraints)
    
//    let solution: [Index: Int] = solve(sudoku.csp)!
    
    let correct = [
      [6, 3, 8, 2, 9, 4, 7, 5, 1],
      [9, 1, 7, 6, 3, 5, 8, 2, 4],
      [5, 2, 4, 7, 1, 8, 6, 3, 9],
      [3, 7, 2, 5, 8, 1, 9, 4, 6],
      [1, 9, 5, 4, 6, 7, 2, 8, 3],
      [8, 4, 6, 9, 2, 3, 5, 1, 7],
      [4, 5, 3, 8, 7, 6, 1, 9, 2],
      [7, 8, 9, 1, 4, 2, 3, 6, 5],
      [2, 6, 1, 3, 5, 9, 4, 7, 8]]
    
    for row in 0...8 {
      for col in 0...8 {
        XCTAssert(correct[row][col] == sudoku.solution[row][col], "Mismatch at (\(row),\(col)) where we have \(sudoku.solution[row][col]) but expected \(correct[row][col])")
      }
    }
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measureBlock() {
      // Put the code you want to measure the time of here.
    }
  }
  
}
