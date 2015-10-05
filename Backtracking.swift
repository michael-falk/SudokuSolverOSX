//
//  Backtracking.swift
//  SudokuSolverOSX
//
//  Created by Michael Falk on 10/1/15.
//  Copyright © 2015 MichaelFalk. All rights reserved.
//

import Foundation

/*
Computed guess at solution to CSP
*/
final class Assignment<T: Hashable, U: Hashable> {
  var varDomains: [T: Set<U>]
  var assignedValues: [T: U?]
  
  init(csp: ConstraintSatisfactionProblem<T, U>) {
    self.varDomains = csp.varDomains
    assignedValues = [:]
    for variable in varDomains.keys {
      assignedValues[variable] = nil as U?
    }
  }
  
  func isAssigned(variable: T) -> Bool {
    if let assignedValue = assignedValues[variable] {
      return (assignedValue != nil)
    }
    return false
  }
  
  func isComplete() -> Bool {
    return Array(assignedValues.keys).map( {self.isAssigned($0)} ).reduce(true, combine: {$0 && $1} )
  }
  
  func extractSolution() -> [T: U]? {
    return isComplete() ? unwrapDictionary(assignedValues) : nil
  }
}

/*
Internal function to remove optional values from a dictionary
*/
func unwrapDictionary<T: Hashable, U: Hashable> (dictionaryWithOptionalValues: [T: U?]) -> [T: U] {
  var out: [T: U] = [:]
  for key in dictionaryWithOptionalValues.keys {
    if let value = dictionaryWithOptionalValues[key] {
      out[key] = value
    }
  }
  return out
}

/*
Modify all current varDomains to remain consistent with Unary Constraints
*/
func eliminateUnaryConstraints<T: Hashable, U: Hashable>(assignment: Assignment<T, U>, csp: ConstraintSatisfactionProblem<T, U>) -> Assignment<T, U>? {
  for variable in assignment.varDomains.keys {
    for constraint in csp.unaryConstraints.filter( {$0.affects(variable)} ) {
      for value in Array(csp.varDomains[variable]!).filter( { !constraint.isSatisfied($0)} ) {
        assignment.varDomains[variable]?.remove(value)
        if (assignment.varDomains[variable]!.count == 0) {
          return nil
        }
      }
    }
  }
  return assignment
}

/*
Check if consistent
*/
func consistent<T: Hashable, U: Hashable>(assignment: Assignment<T, U>, csp: ConstraintSatisfactionProblem<T, U>, variable: T, value: U) -> Bool {
  for binaryConstraint in csp.binaryConstraints {
    if binaryConstraint.affects(variable) {
      let otherVar = binaryConstraint.otherVar(variable)
      if (assignment.isAssigned(otherVar)) {
        if (!assignment.varDomains[variable]!.contains(value) || !binaryConstraint.isSatisfied(assignment.assignedValues[otherVar]!!, value)) {
          return false
        }
      }
    }
  }
  return true
}

/*
Select next variable based on Minimum Remaining Values Heuristic (MRV)
*/
func selectMostConstrainedIndex<T: Hashable, U: Hashable>(assignment: Assignment<T, U>, csp: ConstraintSatisfactionProblem<T, U>) -> T {
  //    CSP variable selection heuristics
  let minimumRemainingValuesHeuristic = {(first: (list:[T], count:Int), second: (list:[T], count:Int)) -> ([T], count:Int) in
    if (first.count > second.count) {
      return second
    } else if (first.count == second.count) {
      return (first.list + second.list, first.count)
    } else {
      return first
    }
  }
  let degree = { (variable: T, csp: ConstraintSatisfactionProblem<T, U>) -> Int in
    return csp.binaryConstraints.filter({$0.affects(variable)}).count
  }
  
  
  let variablesIntermediate: [T] = [T](assignment.varDomains.keys)
  let variables: [T] = variablesIntermediate.filter({!assignment.isAssigned($0)})
  let variablesAndCounts: [([T], Int)] = variables.map({([$0], assignment.varDomains[$0]!.count)})
  let nextVars: [T] = variablesAndCounts.reduce(([], 10), combine: minimumRemainingValuesHeuristic).0
  return nextVars.map({($0, degree($0, csp))}).reduce((nextVars[0], 0), combine: { $1.1 > $0.1 ? $1 : $0}).0
}

/*
Least Constraining Value Heuristic
*/
func orderValuesByLeastConstraining<T: Hashable, U>(assignment: Assignment<T, U>, csp: ConstraintSatisfactionProblem<T, U>, variable: T) -> [U] {
  let values: [U] = Array(assignment.varDomains[variable]!)
  let otherIndices: [T] = csp.binaryConstraints.filter({$0.affects(variable)}).map({$0.otherVar(variable)})
  let constraints: [(U, Int)] = values.map({(value:U) -> (U, Int) in
    (value, otherIndices.map({
      assignment.varDomains[$0]!.count - (assignment.varDomains[$0]!.contains(value) ? 1 : 0)
    }).reduce(0, combine: +))
  })
  return constraints.sort({$0.1 < $1.1}).map({$0.0})
}

func recursiveBackTracking<T: Hashable, U: Hashable>(assignment: Assignment<T, U>,
  csp: ConstraintSatisfactionProblem<T, U>) -> Assignment<T, U>? {
    if assignment.isComplete() {
      return assignment;
    }
    let variable: T = selectMostConstrainedIndex(assignment, csp: csp)
    for value in orderValuesByLeastConstraining(assignment, csp: csp, variable: variable) {
      if (consistent(assignment, csp: csp, variable: variable, value: value)) {
        let prevValue: U? = assignment.assignedValues[variable]!
        assignment.assignedValues[variable] = value
        if let inferences: Set<Inference<T, U>> = forwardChecking(assignment, csp: csp, variable: variable, value: value) {
          if let result = recursiveBackTracking(assignment, csp: csp) {
            return result
          }
          for inference in inferences {
            assignment.varDomains[inference.variable]!.insert(inference.value)
          }
        }
        assignment.assignedValues[variable] = prevValue
      }
    }
    return nil
}

/*
create list of inferences and/or update assignment.varDomains
*/
func forwardChecking<T: Hashable, U: Hashable>(assignment: Assignment<T, U>, csp: ConstraintSatisfactionProblem<T, U>, variable: T, value: U) -> Set<Inference<T, U>>? {
  let otherVariables: [T] = csp.binaryConstraints.filter( {$0.affects(variable)}
    ).map( {$0.otherVar(variable)}
    ).filter( {assignment.varDomains[$0]!.contains(value)} )
  
  var inferences: Set<Inference<T, U>> = []
  for otherVariable in otherVariables {
    if (assignment.varDomains[otherVariable]!.count == 1 && !consistent(assignment, csp: csp, variable: otherVariable, value: value)) {
      for inference in inferences {
        assignment.varDomains[inference.variable]!.insert(value)
      }
      return nil
    }
    if assignment.varDomains[otherVariable]!.contains(value) {
      assignment.varDomains[otherVariable]!.remove(value)
      inferences.insert(Inference<T, U>(variable: otherVariable, value: value))
    }
  }
  return inferences
}

/*
Struct to represent a tuple of a variable and value to remove from the the corresponding varDomain
*/
struct Inference<T: Hashable, U: Hashable>: Equatable {
  let variable: T
  let value: U
  
  init(variable: T, value: U) {
    self.variable = variable
    self.value = value
  }
}

// Mark: - Hashable
extension Inference: Hashable {
  var hashValue: Int {
    return variable.hashValue ^ value.hashValue
  }
}

// MARK: - Equatable
func ==<T: Equatable, U: Equatable> (lhs: Inference<T, U>, rhs: Inference<T, U>) -> Bool {
  return (lhs.variable == rhs.variable) && (lhs.value == rhs.value)
}

/*
Arc-Consistency-3 for preprocessing
*/
func ac3<T: Hashable, U: Hashable>(assignment: Assignment<T, U>, csp: ConstraintSatisfactionProblem<T, U>) -> Assignment<T, U>? {
  func revise(csp: ConstraintSatisfactionProblem<T, U>, binaryConstraint: BinaryConstraint<T, U>) -> Bool {
    var revised: Bool = false
    for x in csp.varDomains[binaryConstraint.var1]! {
      if (Array(csp.varDomains[binaryConstraint.var2]!).filter({binaryConstraint.isSatisfied(x, $0)}).count == 0) {
        csp.varDomains[binaryConstraint.var1]!.remove(x)
        revised = true
      }
    }
    return revised
  }
  
  var queue: [BinaryConstraint] = csp.binaryConstraints
  while !queue.isEmpty {
    let binaryConstraint: BinaryConstraint = queue.removeAtIndex(0)
    if revise(csp, binaryConstraint: binaryConstraint) {
      if (csp.varDomains[binaryConstraint.var1]!.count == 0) {
        return nil
      }
      for otherConstraint in csp.binaryConstraints {
        if (otherConstraint.affects(binaryConstraint.var1) && !otherConstraint.affects(binaryConstraint.var2)) {
          queue.append(otherConstraint)
        }
      }
    }
  }
  return assignment
}

/*
Call complete CSP solver functionality.

Returns the solution: [variable T: value U], if any
*/
public func solve<T: Hashable, U: Hashable>(csp: ConstraintSatisfactionProblem<T, U>) -> [T: U]? {
  if let solution = recursiveBackTracking(ac3(eliminateUnaryConstraints(Assignment<T, U>(csp: csp), csp: csp)!, csp: csp)!, csp: csp) {
    return solution.extractSolution()
  } else {
    return nil
  }
}