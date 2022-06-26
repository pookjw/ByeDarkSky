//
//  WeatherCondition+localizedString.swift
//  ByeDarkSky
//
//  Created by Jinwoo Kim on 6/26/22.
//

import WeatherKit
import ByeDarkSkyCore

extension WeatherCondition {
    var localizedString: String {
        switch self {
        case .blizzard:
            return Localizable.WEATHER_CONDITION_BLIZZARD.localizedString
        case .blowingDust:
            return Localizable.WEATHER_CONDITION_BLOWING_DUST.localizedString
        case .blowingSnow:
            return Localizable.WEATHER_CONDITION_BLOWING_SNOW.localizedString
        case .breezy:
            return Localizable.WEATHER_CONDITION_BREEZY.localizedString
        case .clear:
            return Localizable.WEATHER_CONDITION_CLEAR.localizedString
        case .cloudy:
            return Localizable.WEATHER_CONDITION_CLOUDY.localizedString
        case .drizzle:
            return Localizable.WEATHER_CONDITION_DRIZZLE.localizedString
        case .flurries:
            return Localizable.WEATHER_CONDITION_FLURRIES.localizedString
        case .foggy:
            return Localizable.WEATHER_CONDITION_FOGGY.localizedString
        case .freezingDrizzle:
            return Localizable.WEATHER_CONDITION_FREEZING_DRIZZLE.localizedString
        case .freezingRain:
            return Localizable.WEATHER_CONDITION_FREEZING_RAIN.localizedString
        case .frigid:
            return Localizable.WEATHER_CONDITION_FRIGID.localizedString
        case .hail:
            return Localizable.WEATHER_CONDITION_HAIL.localizedString
        case .haze:
            return Localizable.WEATHER_CONDITION_HAZE.localizedString
        case .heavyRain:
            return Localizable.WEATHER_CONDITION_HEAVY_RAIN.localizedString
        case .heavySnow:
            return Localizable.WEATHER_CONDITION_HEAVY_SNOW.localizedString
        case .hot:
            return Localizable.WEATHER_CONDITION_HOT.localizedString
        case .hurricane:
            return Localizable.WEATHER_CONDITION_HURRICANE.localizedString
        case .isolatedThunderstorms:
            return Localizable.WEATHER_CONDITION_ISOLATED_THUNDERSTORMS.localizedString
        case .mostlyClear:
            return Localizable.WEATHER_CONDITION_MOSTLY_CLEAR.localizedString
        case .mostlyCloudy:
            return Localizable.WEATHER_CONDITION_MOSTLY_CLOUDY.localizedString
        case .partlyCloudy:
            return Localizable.WEATHER_CONDITION_PARTLY_CLOUDY.localizedString
        case .rain:
            return Localizable.WEATHER_CONDITION_RAIN.localizedString
        case .scatteredThunderstorms:
            return Localizable.WEATHER_CONDITION_SCATTERED_THUNDERSTORMS.localizedString
        case .sleet:
            return Localizable.WEATHER_CONDITION_SLEET.localizedString
        case .smoky:
            return Localizable.WEATHER_CONDITION_SMOKY.localizedString
        case .snow:
            return Localizable.WEATHER_CONDITION_SNOW.localizedString
        case .strongStorms:
            return Localizable.WEATHER_CONDITION_STRONG_STORMS.localizedString
        case .sunFlurries:
            return Localizable.WEATHER_CONDITION_SUN_FLURRIES.localizedString
        case .sunShowers:
            return Localizable.WEATHER_CONDITION_SUN_SHOWERS.localizedString
        case .thunderstorms:
            return Localizable.WEATHER_CONDITION_THUNDERSTORMS.localizedString
        case .tropicalStorm:
            return Localizable.WEATHER_CONDITION_TROPICALSTORM.localizedString
        case .windy:
            return Localizable.WEATHER_CONDITION_WINDY.localizedString
        case .wintryMix:
            return Localizable.WEATHER_CONDITION_WINTRY_MIX.localizedString
        @unknown default:
            log.warning("Unhandled case: \(self)")
            return String(describing: self)
        }
    }
}
