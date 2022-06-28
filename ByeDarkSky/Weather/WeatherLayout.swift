//
//  WeatherLayout.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/28/22.
//

import SwiftUI

struct WeatherLayout: Layout {
    let itemSize: CGSize
    
    init(itemSize: CGSize = .init(width: 150, height: 150)) {
        self.itemSize = itemSize
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let largestHorizontalSpacing: CGFloat = subviews.enumerated().reduce(.zero) { partialResult, enumeration in
            let currentIndex: Int = enumeration.offset
            let nextIndex: Int = currentIndex + 1
            
            guard nextIndex < subviews.count else {
                return partialResult
            }

            let currentSubview: LayoutSubview = enumeration.element
            let nextSubview: LayoutSubview = subviews[nextIndex]

            return max(partialResult, currentSubview.spacing.distance(to: nextSubview.spacing, along: .horizontal))
        }
        
        let width: CGFloat = proposal.width ?? .zero
        let spacedWidth: CGFloat = width + largestHorizontalSpacing
        let columnCount: Int = Int(trunc(spacedWidth / (itemSize.width + largestHorizontalSpacing)))
        guard columnCount > 0 else { return .zero }
        let rowCount: Int = (subviews.count / columnCount) + ((subviews.count % columnCount == .zero) ? .zero : 1)
        
        let totalVerticalSpacing: CGFloat = (0..<rowCount).reduce(.zero) { partialResult1, row in
            let startIndex: Int = row * columnCount
            let endIndex: Int = startIndex + columnCount - 1
            
            guard endIndex < subviews.count else {
                return partialResult1
            }
            
            let largestVerticalSpacing: CGFloat = (startIndex...endIndex).reduce(.zero) { partialResult2, index in
                let currentIndex: Int = index
                let nextIndex: Int = index + columnCount
                
                guard nextIndex < subviews.count else {
                    return partialResult2
                }
                
                let currentSubview: LayoutSubview = subviews[currentIndex]
                let nextSubview: LayoutSubview = subviews[nextIndex]
                
                return max(partialResult2, currentSubview.spacing.distance(to: nextSubview.spacing, along: .vertical))
            }
            
            return partialResult1 + largestVerticalSpacing
        }
        
//        let finalWidth: CGFloat = (CGFloat(columnCount) * itemSize.width) + (CGFloat(columnCount - 1) * largestHorizontalSpacing)
        let finalHeight: CGFloat = (CGFloat(rowCount) * itemSize.height) + CGFloat(totalVerticalSpacing)
        
        return .init(width: width, height: finalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let largestHorizontalSpacing: CGFloat = subviews.enumerated().reduce(.zero) { partialResult, enumeration in
            let currentIndex: Int = enumeration.offset
            let nextIndex: Int = currentIndex + 1
            
            guard nextIndex < subviews.count else {
                return partialResult
            }

            let currentSubview: LayoutSubview = enumeration.element
            let nextSubview: LayoutSubview = subviews[nextIndex]

            return max(partialResult, currentSubview.spacing.distance(to: nextSubview.spacing, along: .horizontal))
        }
        
        let width: CGFloat = bounds.width
        let spacedWidth: CGFloat = width + largestHorizontalSpacing
        let columnCount: Int = Int(trunc(spacedWidth / (itemSize.width + largestHorizontalSpacing)))
        guard columnCount > 0 else { return }
        let rowCount: Int = (subviews.count / columnCount) + ((subviews.count % columnCount == .zero) ? .zero : 1)
        var yPosition: CGFloat = .zero
        
        (0..<rowCount).forEach { row in
            let totalWidth: CGFloat = ((row)...(row + columnCount - 1)).reduce(.zero) { partialResult, column in
                let currentIndex: Int = column
                let nextIndex: Int = currentIndex + 1
                
                guard nextIndex < subviews.count else {
                    return partialResult + itemSize.width
                }
                
                let currentSubview: LayoutSubview = subviews[currentIndex]
                let nextSubview: LayoutSubview = subviews[nextIndex]
                let spacing: CGFloat = currentSubview.spacing.distance(to: nextSubview.spacing, along: .horizontal)
                
                return partialResult + itemSize.width + spacing
            }
            
            let horizontalSpacing: CGFloat = (bounds.width - totalWidth) / CGFloat(2)
            let verticalSpacing: CGFloat = {
                let startIndex: Int = row * columnCount
                let endIndex: Int = startIndex + columnCount - 1
                
                guard endIndex < subviews.count else {
                    return .zero
                }
                
                let largestVerticalSpacing: CGFloat = (startIndex...endIndex).reduce(.zero) { partialResult2, index in
                    let currentIndex: Int = index
                    let nextIndex: Int = index + columnCount
                    
                    guard nextIndex < subviews.count else {
                        return partialResult2
                    }
                    
                    let currentSubview: LayoutSubview = subviews[currentIndex]
                    let nextSubview: LayoutSubview = subviews[nextIndex]
                    
                    return max(partialResult2, currentSubview.spacing.distance(to: nextSubview.spacing, along: .vertical))
                }
                
                return largestVerticalSpacing
            }()
            var xPosition: CGFloat = horizontalSpacing
            
            ((row * columnCount)...(row * columnCount + columnCount - 1)).forEach { column in
                let currentIndex: Int = column
                
                guard currentIndex < subviews.count else {
                    return
                }
                
                let nextIndex: Int = currentIndex + 1
                let currentSubview: LayoutSubview = subviews[currentIndex]
                
                currentSubview.place(at: .init(x: xPosition, y: yPosition), anchor: .topLeading, proposal: .init(itemSize))
                
                if nextIndex >= subviews.count {
                    xPosition += itemSize.width
                } else {
                    let nextSubview: LayoutSubview = subviews[nextIndex]
                    let spacing: CGFloat = currentSubview.spacing.distance(to: nextSubview.spacing, along: .horizontal)
                    xPosition += itemSize.width + spacing
                }
            }
            
            yPosition += itemSize.height + verticalSpacing
        }
    }
    
    func makeCache(subviews: Subviews) -> () {
        
    }
}
