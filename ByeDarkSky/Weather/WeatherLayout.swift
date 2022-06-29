//
//  WeatherLayout.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/28/22.
//

import SwiftUI
import ByeDarkSkyCore

fileprivate final class WeatherLayoutCacheStore: ObservableObject {
    static let shared: WeatherLayoutCacheStore = .init()
    var caches: [UUID: LayoutSubviews] = [:]
    var sizes: [UUID: CGSize] = [:]
}

struct WeatherLayout: Layout {
    typealias Cache = UUID
    
    enum ContentMode {
        case fill, fit
    }
    
    private let itemSize: CGSize
    private let horizontalContentMode: ContentMode
    
    private var cacheStore: WeatherLayoutCacheStore = .shared
    
    init(itemSize: CGSize = .init(width: 150, height: 150), horizontalContentMode: ContentMode = .fit) {
        self.itemSize = itemSize
        self.horizontalContentMode = horizontalContentMode
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout UUID) -> CGSize {
        if let size: CGSize = cacheStore.sizes[cache] {
            return size
        } else {
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
            
            let finalSize: CGSize
            let finalHeight: CGFloat = (CGFloat(rowCount) * itemSize.height) + CGFloat(totalVerticalSpacing)
            
            switch horizontalContentMode {
            case .fit:
                let finalWidth: CGFloat = (CGFloat(columnCount) * itemSize.width) + (CGFloat(columnCount - 1) * largestHorizontalSpacing)
                finalSize = .init(width: finalWidth, height: finalHeight)
            case .fill:
                finalSize = .init(width: width, height: finalHeight)
            }
            
            cacheStore.sizes[cache] = finalSize
            return finalSize
        }
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout UUID) {
        log.debug("Creating new")
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
    
    func makeCache(subviews: Subviews) -> UUID {
        if let _cache: UUID = cacheStore.caches.first(where: { $0.value == subviews })?.key {
            log.debug("Cached!!!")
            return _cache
        } else {
            log.debug(cacheStore.caches)
            let cache: UUID = .init()
            cacheStore.caches[cache] = subviews
            return cache
        }
    }
    
    func updateCache(_ cache: inout UUID, subviews: Subviews) {
        if let _cache: UUID = cacheStore.caches.first(where: { $0.value == subviews })?.key {
            log.debug("Cached!!!")
            cache = _cache
        } else {
            log.debug(cacheStore.caches)
//            log.debug("")
//            let newCache: UUID = makeCache(subviews: subviews)
//            cache = newCache
        }
    }
}
