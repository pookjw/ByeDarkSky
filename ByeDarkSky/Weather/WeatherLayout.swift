//
//  WeatherLayout.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/28/22.
//

import SwiftUI
import ByeDarkSkyCore

fileprivate final class WeatherLayoutCacheStore: ObservableObject {
    struct Geometry: Hashable {
        let bounds: CGRect?
        let proposal: ProposedViewSize
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(bounds?.origin.x)
            hasher.combine(bounds?.origin.y)
            hasher.combine(bounds?.size.width)
            hasher.combine(bounds?.size.height)
            hasher.combine(proposal.width)
            hasher.combine(proposal.height)
        }
    }
    
    var sizes: [UUID: [Geometry: CGSize]] = [:]
    var locations: [UUID: [Geometry: [CGPoint]]] = [:]
}

struct WeatherLayout: Layout {
    typealias Cache = UUID
    
    enum ContentMode {
        case fill, fit
    }
    
    private let itemSize: CGSize
    private let horizontalContentMode: ContentMode
    
    private var cacheStore: WeatherLayoutCacheStore = .init()
    private let useCache: Bool = true
    
    init(itemSize: CGSize = .init(width: 150, height: 150), horizontalContentMode: ContentMode = .fit) {
        self.itemSize = itemSize
        self.horizontalContentMode = horizontalContentMode
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout UUID) -> CGSize {
        let geometry: WeatherLayoutCacheStore.Geometry = .init(bounds: nil, proposal: proposal)
        
        if let size: CGSize = cacheStore.sizes[cache]?[geometry], useCache {
            log.debug("Cached!")
            return size
        } else {
            log.debug("Creating new...")
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
            
            var sizes: [WeatherLayoutCacheStore.Geometry: CGSize] = cacheStore.sizes[cache, default: [:]]
            sizes[geometry] = finalSize
            cacheStore.sizes[cache] = sizes
            
            return finalSize
        }
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout UUID) {
        let geometry: WeatherLayoutCacheStore.Geometry = .init(bounds: bounds, proposal: proposal)
        
        if let locations: [CGPoint] = cacheStore.locations[cache]?[geometry], useCache {
            log.debug("Cached!")
            subviews.enumerated().forEach { enumeration in
                let index: Int = enumeration.offset
                let subview: LayoutSubview = enumeration.element
                let location: CGPoint = locations[index]
                subview.place(at: location, anchor: .topLeading, proposal: .init(itemSize))
            }
        } else {
            log.debug("Creating new...")
            
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
            var yPosition: CGFloat = bounds.origin.y
            var locations: [CGPoint] = []
            
            (0..<rowCount).forEach { row in
                let firstColumn: Int = row * columnCount
                let lastColumn: Int = {
                    // for last row
                    let tmp: Int = firstColumn + columnCount - 1
                    
                    if tmp < subviews.count {
                        return tmp
                    } else {
                        return subviews.count - 1
                    }
                }()
                
                let totalWidth: CGFloat = (firstColumn...lastColumn).reduce(.zero) { partialResult, currentIndex in
                    let nextIndex: Int = currentIndex + 1
                    
                    guard (currentIndex < lastColumn) && (nextIndex < subviews.count) else {
                        return partialResult + itemSize.width
                    }
                    
                    let currentSubview: LayoutSubview = subviews[currentIndex]
                    let nextSubview: LayoutSubview = subviews[nextIndex]
                    let spacing: CGFloat = currentSubview.spacing.distance(to: nextSubview.spacing, along: .horizontal)
                    
                    return partialResult + itemSize.width + spacing
                }
                
                log.debug(totalWidth)
                
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
                var xPosition: CGFloat = bounds.origin.x + horizontalSpacing
                
                (firstColumn...lastColumn).forEach { currentIndex in
                    guard currentIndex < subviews.count else {
                        return
                    }
                    
                    let currentSubview: LayoutSubview = subviews[currentIndex]
                    currentSubview.place(at: .init(x: xPosition, y: yPosition), anchor: .topLeading, proposal: .init(itemSize))
                    locations.append(.init(x: xPosition, y: yPosition))
                    
                    let nextIndex: Int = currentIndex + 1
                    
                    if (currentIndex < lastColumn) && (nextIndex < subviews.count) {
                        let nextSubview: LayoutSubview = subviews[nextIndex]
                        let spacing: CGFloat = currentSubview.spacing.distance(to: nextSubview.spacing, along: .horizontal)
                        xPosition += itemSize.width + spacing
                    }
                }
                
                yPosition += itemSize.height + verticalSpacing
            }
            
            var _locations: [WeatherLayoutCacheStore.Geometry: [CGPoint]] = cacheStore.locations[cache, default: [:]]
            _locations[geometry] = locations
            cacheStore.locations[cache] = _locations
        }
    }
    
    func explicitAlignment(of guide: HorizontalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout UUID) -> CGFloat? {
        return nil
    }

    func explicitAlignment(of guide: VerticalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout UUID) -> CGFloat? {
        return nil
    }
    
    func makeCache(subviews: Subviews) -> UUID {
        let cache: UUID = .init()
        return cache
    }
    
    func updateCache(_ cache: inout UUID, subviews: Subviews) {
        cache = .init()
    }
}
