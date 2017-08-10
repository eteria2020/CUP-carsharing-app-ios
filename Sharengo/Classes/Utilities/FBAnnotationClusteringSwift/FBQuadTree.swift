//
//  FBQuadTree.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import GoogleMaps

open class FBQuadTree {
    
    let rootNode = FBQuadTreeNode(boundingBox: FBBoundingBox(mapRect: MKMapRectWorld))

	// MARK: Internal functions
    
    func insert(annotation: GMSMarker) -> Bool {
        return insert(annotation: annotation, toNode:rootNode)
    }

    func enumerateAnnotations(inBox box: FBBoundingBox, callback: (GMSMarker) -> Void) {
		enumerateAnnotations(inBox: box, withNode:rootNode, callback: callback)
    }
    
    func enumerateAnnotationsUsingBlock(_ callback: (GMSMarker) -> Void) {
		enumerateAnnotations(inBox: FBBoundingBox(mapRect: MKMapRectWorld), withNode:rootNode, callback:callback)
    }

	// MARK: Private functions

	private func insert(annotation: GMSMarker, toNode node: FBQuadTreeNode) -> Bool {
		if !node.boundingBox.contains(coordinate: annotation.position) {
			return false
		}

		if node.canAppendAnnotation() {
			return node.append(annotation: annotation)
		}

		let siblings = node.siblings() ?? node.createSiblings()

		if insert(annotation: annotation, toNode:siblings.northEast) {
			return true
		}

		if insert(annotation: annotation, toNode:siblings.northWest) {
			return true
		}

		if insert(annotation: annotation, toNode:siblings.southEast) {
			return true
		}

		if insert(annotation: annotation, toNode:siblings.southWest) {
			return true
		}

		return false
	}

    private func enumerateAnnotations(inBox box: FBBoundingBox, withNode node: FBQuadTreeNode, callback: (GMSMarker) -> Void) {
        if !node.boundingBox.intersects(box2: box) {
            return
        }

        for annotation in node.annotations {
            if box.contains(coordinate: annotation.position) {
                callback(annotation)
            }
        }
        
        if node.isLeaf() {
            return
        }

		if let northEast = node.northEast {
			enumerateAnnotations(inBox: box, withNode: northEast, callback: callback)
		}

		if let northWest = node.northWest {
			enumerateAnnotations(inBox: box, withNode: northWest, callback: callback)
		}

		if let southEast = node.southEast {
			enumerateAnnotations(inBox: box, withNode: southEast, callback: callback)
		}

		if let southWest = node.southWest {
			enumerateAnnotations(inBox: box, withNode: southWest, callback: callback)
		}
    }
}
