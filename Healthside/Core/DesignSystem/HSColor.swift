//
//  HSColor.swift
//  Healthside
//
//  Палитра дизайн-системы (тёплая, светлая тема). Значения живут как именованные
//  цвета в Assets.xcassets, здесь — только алиасы на сгенерированные SwiftGen'ом
//  Asset.* (Generated/Assets.swift), чтобы не переписывать все места использования.
//  TODO: dark-варианты, когда появятся в дизайне.
//

import SwiftUI

public enum HSColor {
    // Поверхности
    public static let background = Asset.background.swiftUIColor
    public static let surface = Asset.surface.swiftUIColor

    // Текст
    public static let ink = Asset.ink.swiftUIColor                   // основной
    public static let inkSecondary = Asset.inkSecondary.swiftUIColor // подписи/вторичный
    public static let placeholder = Asset.placeholder.swiftUIColor
    public static let textDisabled = Asset.textDisabled.swiftUIColor
    public static let labelDisabled = Asset.labelDisabled.swiftUIColor

    // Поля ввода
    public static let fieldFill = Asset.fieldFill.swiftUIColor
    public static let fieldFillDisabled = Asset.fieldFillDisabled.swiftUIColor
    public static let hairline = Asset.hairline.swiftUIColor

    // Акцент (коралл)
    public static let coral = Asset.coral.swiftUIColor
    public static let coralRing = Asset.coralRing.swiftUIColor
    public static let coralSoft = Asset.coralSoft.swiftUIColor // мягкий фон под коралловые иконки

    // Статусы
    public static let danger = Asset.danger.swiftUIColor
    public static let dangerFill = Asset.dangerFill.swiftUIColor
    public static let dangerBorder = Asset.dangerBorder.swiftUIColor
    public static let success = Asset.success.swiftUIColor
    public static let successBorder = Asset.successBorder.swiftUIColor
    public static let successFill = Asset.successFill.swiftUIColor
    public static let warning = Asset.warning.swiftUIColor
    public static let warningFill = Asset.warningFill.swiftUIColor
}
