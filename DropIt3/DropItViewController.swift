//
//  DropItViewController.swift
//  DropIt
//
//  Created by iMac21.5 on 4/29/15.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import UIKit

class DropItViewController: UIViewController, UIDynamicAnimatorDelegate {

    @IBOutlet weak var gameView: BezierPathView!
    
    lazy var animator: UIDynamicAnimator = {
        let lazyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazyCreatedDynamicAnimator.delegate = self
        return lazyCreatedDynamicAnimator
    }()
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        removeCompletedRow()
    }
    
    let dropItBehavior = DropItBehavior()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(dropItBehavior)
    }
    
    struct PathNames {
        static let MiddleBarrier = "Middle Barrier"
        static let Attachment = "Attachment"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let barrierSize = dropSize
        let barrierOrigin = CGPoint(x: gameView.bounds.midX - barrierSize.width / 2, y: gameView.bounds.midY - barrierSize.height / 2)
        let path = UIBezierPath(ovalInRect: CGRect(origin: barrierOrigin, size: barrierSize))
        dropItBehavior.addBarrier(path, named: PathNames.MiddleBarrier)
        //comment next line to hide barrier
        gameView.setPath(path, named: PathNames.MiddleBarrier)
    }
    
    var dropsPerRow: Int {
        let model = UIDevice.currentDevice().model
        if model.hasPrefix("iPad") {
            return 20
            }
            else { return 10 }
    }
    var dropSize: CGSize {
        let w = gameView.bounds.size.width / CGFloat(dropsPerRow)
        let h = gameView.bounds.size.height / CGFloat(dropsPerRow)
        return CGSize(width: w, height: h)
    }
    var attachment: UIAttachmentBehavior? {
        willSet {
            if attachment != nil {
                animator.removeBehavior(attachment!)
            }
            gameView.setPath(nil, named: PathNames.Attachment)
        }
        didSet {
            if attachment != nil {
                animator.addBehavior(attachment!)
                attachment?.action = { [unowned self] in
                    if let attachedView = self.attachment?.items.first as? UIView {
                        let path = UIBezierPath()
                        path.moveToPoint(self.attachment!.anchorPoint)
                        path.addLineToPoint(attachedView.center)
                        self.gameView.setPath(path, named: PathNames.Attachment)
                    }
                }
            }
        }
    }
    var lastDroppedView: UIView?
    
    @IBAction func grabDrop(sender: UIPanGestureRecognizer) {
        let gesturePoint = sender.locationInView(gameView)
        switch sender.state {
        case .Began:
            if let viewToAttachTo = lastDroppedView {
//                attachment = UIAttachmentBehavior(item: viewToAttachTo, attachedToAnchor: gesturePoint)
                attachment = UIAttachmentBehavior(item: viewToAttachTo, offsetFromCenter: UIOffset(horizontal: 5.0, vertical: 5.0), attachedToAnchor: gesturePoint)
                lastDroppedView = nil //so cannot pan/attach to again
            }
        case .Changed:
            attachment?.anchorPoint = gesturePoint
        case .Ended:
            attachment = nil
        default: break
        }
    }
    
    @IBAction func drop(sender: UITapGestureRecognizer) {
        drop()
    }
    
    func drop() {
        var frame = CGRect(origin: CGPointZero, size: dropSize)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        
        let dropView = Oval(frame: frame)
//        let dropView = UIView(frame: frame)
        dropView.backgroundColor = UIColor.whiteColor()
        lastDroppedView = dropView
        dropItBehavior.addDrop(dropView)
    }
    
    func removeCompletedRow() {
        var dropsToRemove = [UIView]()
        var dropFrame = CGRect(x: 0, y: gameView.frame.maxY, width: dropSize.width, height: dropSize.height)
            repeat {print(dropFrame.origin)
                dropFrame.origin.y -= dropSize.height
                dropFrame.origin.x = 0
                var dropsFound = [UIView]()
                var rowIsComplete = true
                for _ in 0 ..< dropsPerRow {
                    if let hitView = gameView.hitTest(CGPoint(x: dropFrame.midX, y: dropFrame.midY), withEvent: nil) {
                        if hitView.superview == gameView {
                            dropsFound.append(hitView)
                        } else {
                            rowIsComplete = false
                        }
                    }
                    dropFrame.origin.x += dropSize.width
                }
                if rowIsComplete {
                    dropsToRemove += dropsFound
                }
            } while dropsToRemove.count == 0 && dropFrame.origin.y > 0
        
        for drop in dropsToRemove {
            dropItBehavior.removeDrop(drop)
        }
    }
}

private extension CGFloat {
    static func random(max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}