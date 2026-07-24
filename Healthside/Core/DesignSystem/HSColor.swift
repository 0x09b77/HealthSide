//
//  HSColor.swift
//  Healthside
//
//  Палитра дизайн-системы (тёплая, светлая тема). Значения — из Design System.
//  TODO: dark-варианты, когда появятся в дизайне.
//

import SwiftUI

public enum HSColor {
    // Поверхности
    public static let background = Color(hex: 0xFBF8F4)
    public static let surface = Color(hex: 0xFFFFFF)

    // Текст
    public static let ink = Color(hex: 0x2A2724)          // основной
    public static let inkSecondary = Color(hex: 0x6E655C) // подписи/вторичный
    public static let placeholder = Color(hex: 0xA99E8E)
    public static let textDisabled = Color(hex: 0xC3BAAC)
    public static let labelDisabled = Color(hex: 0xB4AB9E)

    // Поля ввода
    public static let fieldFill = Color(hex: 0xF4EEE6)
    public static let fieldFillDisabled = Color(hex: 0xF1ECE4)
    public static let hairline = Color(hex: 0xE4D9C8)

    // Акцент (коралл)
    public static let coral = Color(hex: 0xE8734A)
    public static let coralRing = Color(hex: 0xE8734A).opacity(0.14)
    public static let coralSoft = Color(hex: 0xFBE4D8) // мягкий фон под коралловые иконки

    // Статусы
    public static let danger = Color(hex: 0xC0523C)
    public static let dangerFill = Color(hex: 0xF7E1DB)
    public static let dangerBorder = Color(hex: 0xE0917F)
    public static let success = Color(hex: 0x3F9A6F)
    public static let successBorder = Color(hex: 0x86C4A3)
    public static let successFill = Color(hex: 0xE7F1EA)
    public static let warning = Color(hex: 0xC6892B)
    public static let warningFill = Color(hex: 0xFBEED6)
}

public extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
