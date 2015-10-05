//
//  CSP.swift
//  SudokuSolverOSX
//
//  Created by Michael Falk on 10/1/15.
//  Copyright © 2015 MichaelFalk. All rights reserved.
//

import Foundation

/*
Representation of Constraint Satisfaction Problem to solve
*/
public final class ConstraintSatisfactionProblem<T: Hashable, U: Hashable> {
  var varDomains: [T: Set<U>]
  var unaryConstraints: [UnaryConstraint<T, U>]
  var binaryConstraints: [BinaryConstraint<T, U>]
  
  public init(unaryConstraints: [UnaryConstraint<T, U>], binaryConstraints: [BinaryConstraint<T, U>], varDomains: [T: Set<U>]) {
    self.unaryConstraints = unaryConstraints
    self.binaryConstraints = binaryConstraints
    self.varDomains = varDomains
  }
}