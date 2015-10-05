//
//  SudokuCSP.swift
//  SudokuSolverOSX
//
//  Created by Michael Falk on 10/1/15.
//  Copyright © 2015 MichaelFalk. All rights reserved.
//

import Foundation

// Index in sudoku table in range of [1..9][1..9]
public struct Index: Equatable {
  var x: Int
  var y: Int
  var group: Int
  
  public init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
    self.group = (1 + ((x - 1) / 3)) + (3 * ((y - 1) / 3))
  }
}

extension Index: Hashable {
  public var hashValue: Int {
    return  x + (9 * (y - 1))
  }
}

// Index: Equatable
public func == (lhs: Index, rhs: Index) -> Bool {
  return (lhs.x == rhs.x) && (lhs.y == rhs.y)
}

public class SudokuSolver {
  public var solution: [[Int]]
  
  public init(unaryConstraints: [UnaryConstraint<Index, Int>]) {
    
    //  Use set to remove duplicates
    var binaryConstraints: Set<BinaryConstraint<Index, Int>> = []
    
    var varDomains: [Index: Set<Int>] = [:]
    let indices: [Index] = [1,2,3,4,5,6,7,8,9].flatMap( {x in [1,2,3,4,5,6,7,8,9].map( {y in Index(x, y)} )} )
    for index in indices {
      varDomains[index] = Set([1,2,3,4,5,6,7,8,9])
    }
    
    for i in indices {
      for j in indices {
        if i != j {
          if (i.x == j.x) || (i.y == j.y) || (i.group == j.group) {
            binaryConstraints.insert(NEQConstraint(var1: i, var2: j));
          }
        }
      }
    }
    
    self.solution = [[Int]](count:9, repeatedValue:[Int](count:9, repeatedValue:0))
    for (index, value) in solve(ConstraintSatisfactionProblem<Index, Int>(unaryConstraints: unaryConstraints, binaryConstraints: Array(binaryConstraints), varDomains: varDomains))! {
      self.solution[index.x-1][index.y-1] = value
    }
  }
  
}


