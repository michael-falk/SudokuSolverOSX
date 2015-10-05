//
//  ViewController.swift
//  SudokuSolverOSX
//
//  Created by Michael Falk on 10/1/15.
//  Copyright © 2015 MichaelFalk. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

  @IBOutlet weak var collectionView: NSCollectionView!
  override func viewDidLoad() {
    super.viewDidLoad()

    self.collectionView.itemPrototype = self.storyboard?.instantiateControllerWithIdentifier("collectionViewItem") as? NSCollectionViewItem
  }

  override var representedObject: AnyObject? {
    didSet {
    // Update the view, if already loaded.
    }
  }


}

