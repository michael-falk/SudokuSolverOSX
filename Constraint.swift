//
//  Constraint.swift
//  SudokuSolverOSX
//
//  Created by Michael Falk on 10/1/15.
//  Copyright © 2015 MichaelFalk. All rights reserved.
//

import Foundation

/*
1 variable constraint
*/
public class UnaryConstraint<T:Hashable, U: Hashable> {
  public let variable: T
  public let satisfactionFunction: U -> Bool
  public let satisfactionFunctionID: String
  
  init(satisfactionFunction: U -> Bool, satisfactionFunctionID: String, variable: T)  {
    self.variable = variable
    self.satisfactionFunction = satisfactionFunction
    self.satisfactionFunctionID = satisfactionFunctionID
  }
  
  func isSatisfied(value: U) -> Bool {
    return self.satisfactionFunction(value)
  }
  
  func affects(variable: T) -> Bool {
    return (variable == self.variable)
  }
  
}

// MARK: - Hashable
extension UnaryConstraint: Hashable {
  public var hashValue: Int {
    return variable.hashValue ^ satisfactionFunctionID.hashValue
  }
}

// MARK: - Equatable
public func ==<T: Equatable, U: Equatable> (lhs: UnaryConstraint<T, U>, rhs: UnaryConstraint<T, U>) -> Bool {
  return (lhs.variable == rhs.variable) && (lhs.satisfactionFunctionID == rhs.satisfactionFunctionID)
}

//Some common constraints
public final class BadValueConstraint<T:Hashable, U: Hashable>: UnaryConstraint<T, U> {
  public init(variable: T, badValue: U) {
    super.init(satisfactionFunction: { $0 != badValue}, satisfactionFunctionID: "!= \(badValue)", variable: variable)
  }
}

public final class GoodValueConstraint<T:Hashable, U: Hashable>: UnaryConstraint<T, U> {
  public init(variable: T, goodValue: U) {
    super.init(satisfactionFunction: { $0 == goodValue}, satisfactionFunctionID: "!= \(goodValue)", variable: variable)
  }
}

/*
2 variable constraint
*/
public class BinaryConstraint<T: Hashable, U: Hashable> {
  let var1: T
  let var2: T
  let satisfactionFunction: (U, U) -> Bool
  let satisfactionFunctionID: String
  
  public init(satisfactionFunction: (U, U) -> Bool, satisfactionFunctionID: String, var1: T, var2: T)  {
    self.var1 = var1
    self.var2 = var2
    self.satisfactionFunction = satisfactionFunction
    self.satisfactionFunctionID = satisfactionFunctionID
  }
  
  public func isSatisfied(value1: U, _ value2: U) -> Bool {
    return self.satisfactionFunction(value1, value2)
  }
  
  public func affects(variable: T) -> Bool {
    return (variable == self.var1) || (variable == self.var2)
  }
  
  public func otherVar(variable: T) -> T {
    return variable == var1 ? var2 : var1
  }
}

// MARK: - Hashable
extension BinaryConstraint: Hashable {
  public var hashValue: Int {
    return (var1.hashValue + var2.hashValue) ^ satisfactionFunctionID.hashValue
  }
}

// MARK: - Equatable
public func ==<T: Equatable, U: Equatable> (lhs: BinaryConstraint<T, U>, rhs: BinaryConstraint<T, U>) -> Bool {
  return (((lhs.var1 == rhs.var1) && (lhs.var2 == rhs.var2)) || ((lhs.var2 == rhs.var1) && (lhs.var1 == rhs.var2))) && (lhs.satisfactionFunctionID == rhs.satisfactionFunctionID)
}

//Some common constraints
public final class EQConstraint<T: Hashable, U: Hashable>: BinaryConstraint<T, U> {
  public init(var1: T, var2: T) {
    super.init(satisfactionFunction: {(x: U, y: U) -> Bool in return (x == y)}, satisfactionFunctionID: "==", var1: var1, var2: var2)
  }
}

public final class NEQConstraint<T: Hashable, U: Hashable>: BinaryConstraint<T, U> {
  public init(var1: T, var2: T) {
    super.init(satisfactionFunction: (!=), satisfactionFunctionID: "!=", var1: var1, var2: var2)
  }
}
