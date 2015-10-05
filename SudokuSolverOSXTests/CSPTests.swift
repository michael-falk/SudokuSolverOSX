//
//  CSPTests.swift
//  SudokuSolver
//
//  Created by Michael Falk on 7/26/15.
//  Copyright (c) 2015 MichaelFalk. All rights reserved.
//

import Cocoa
import XCTest
import SudokuSolverOSX

class CSPTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measureBlock() {
      // Put the code you want to measure the time of here.
    }
  }
  
  
  
  func testBacktracking1Impossible() {
    var varDomains: [String: Set<String>] = [:]
    for variable in ["A", "B", "C", "D", "E", "F", "G"] {
      varDomains[variable] = Set(["R", "G", "B"])
    }
    
    let binaryConstraints: [BinaryConstraint<String, String>] = [NEQConstraint(var1: "A", var2: "B"), NEQConstraint(var1: "A", var2: "D"), NEQConstraint(var1: "B", var2: "C"), NEQConstraint(var1: "B", var2: "D"),NEQConstraint(var1: "C", var2: "D"), NEQConstraint(var1: "C", var2: "E"), NEQConstraint(var1: "D", var2: "E"), NEQConstraint(var1: "D", var2: "F"), NEQConstraint(var1: "E", var2: "F"), NEQConstraint(var1: "E", var2: "G"), NEQConstraint(var1: "F", var2: "G"), NEQConstraint(var1: "D", var2: "G")]
    
    let csp: ConstraintSatisfactionProblem<String, String> = ConstraintSatisfactionProblem(unaryConstraints: [], binaryConstraints: binaryConstraints, varDomains: varDomains)
    
    XCTAssert(solve(csp) == nil, "Non-nil solution returned for impossible CSP")
  }
  
  func testBacktracking2Solvable() {
    var varDomains: [String: Set<String>] = [:]
    for variable in ["A", "B", "C", "D", "E", "F", "G"] {
      varDomains[variable] = Set(["R", "G", "B"])
    }
    
    let binaryConstraints: [BinaryConstraint<String, String>] = [NEQConstraint(var1: "A", var2: "B"), NEQConstraint(var1: "A", var2: "D"), NEQConstraint(var1: "B", var2: "C"), NEQConstraint(var1: "B", var2: "D"),NEQConstraint(var1: "C", var2: "D"), NEQConstraint(var1: "C", var2: "E"), NEQConstraint(var1: "D", var2: "E"), NEQConstraint(var1: "D", var2: "F"), NEQConstraint(var1: "E", var2: "F"), NEQConstraint(var1: "E", var2: "G"), NEQConstraint(var1: "F", var2: "G")]
    
    let unaryConstraints: [UnaryConstraint<String, String>] = [BadValueConstraint(variable: "A", badValue: "B"), BadValueConstraint(variable: "D", badValue: "G"), BadValueConstraint(variable: "G", badValue: "B")]
    
    let csp: ConstraintSatisfactionProblem<String, String> = ConstraintSatisfactionProblem(unaryConstraints: unaryConstraints, binaryConstraints: binaryConstraints, varDomains: varDomains)
    
    let assignment: [String: String] = solve(csp)!
    let correct: [String: String] = ["A": "G", "B": "B", "C": "G", "D": "R", "E": "B", "F": "G", "G": "R"]
//    XCTAssert(success, "Invalid solution for CSP without constraints")
    XCTAssertEqualDictionaries(assignment, correct)
    
  }
  
  func XCTAssertEqualDictionaries<S, T: Equatable>(first: [S:T], _ second: [S:T]) {
    XCTAssert(first == second)
  }
  
}
