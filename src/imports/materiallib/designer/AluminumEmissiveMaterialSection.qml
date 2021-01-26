/****************************************************************************
**
** Copyright (C) 2021 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of Qt Quick 3D.
**
** $QT_BEGIN_LICENSE:COMM$
**
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** $QT_END_LICENSE$
**
**
**
**
**
**
**
**
**
****************************************************************************/

import QtQuick 2.15
import HelperWidgets 2.0
import QtQuick.Layouts 1.12
import StudioTheme 1.0 as StudioTheme

Column {
    id: materialRoot
    width: parent.width

    property int labelWidth: 10
    property int labelSpinBoxSpacing: 0
    property int spinBoxMinimumWidth: 120

    Section {
        caption: qsTr("Environment Map")
        width: parent.width

        SectionLayout {
            Label {
                text: qsTr("Enabled")
                tooltip: qsTr("Specifies if the environment map is enabled.")
            }
            SecondColumnLayout {
                CheckBox {
                    text: backendValues.uEnvironmentMappingEnabled.valueToString
                    backendValue: backendValues.uEnvironmentMappingEnabled
                    Layout.fillWidth: true
                }
            }
            Label {
                text: qsTr("Texture")
                tooltip: qsTr("Defines a texture for environment map.")
            }
            SecondColumnLayout {
                IdComboBox {
                    typeFilter: "QtQuick3D.Texture"
                    Layout.fillWidth: true
                    backendValue: backendValues.uEnvironmentTexture_texture
                    defaultItem: qsTr("Default")
                }
            }
        }
    }

    Section {
        caption: qsTr("Shadow Map")
        width: parent.width

        SectionLayout {
            Label {
                text: qsTr("Enabled")
                tooltip: qsTr("Specifies if the shadow map is enabled.")
            }
            SecondColumnLayout {
                CheckBox {
                    text: backendValues.uShadowMappingEnabled.valueToString
                    backendValue: backendValues.uShadowMappingEnabled
                    Layout.fillWidth: true
                }
            }
            Label {
                text: qsTr("Texture")
                tooltip: qsTr("Defines a texture for shadow map.")
            }
            SecondColumnLayout {
                IdComboBox {
                    typeFilter: "QtQuick3D.Texture"
                    Layout.fillWidth: true
                    backendValue: backendValues.uBakedShadowTexture_texture
                    defaultItem: qsTr("Default")
                }
            }
        }
    }

    Section {
        caption: qsTr("Emission")
        width: parent.width
        ColumnLayout {
            width: parent.width - 16
            SectionLayout {
                Label {
                    text: qsTr("Intensity")
                    tooltip: qsTr("Set the emission intensity.")
                }
                SecondColumnLayout {
                    SpinBox {
                        maximumValue: 1
                        minimumValue: 0
                        decimals: 2
                        stepSize: 0.1
                        backendValue: backendValues.intensity
                        Layout.fillWidth: true
                    }
                }
            Label {
                text: qsTr("Map Texture")
                tooltip: qsTr("Defines a texture for emissive map.")
            }
            SecondColumnLayout {
                IdComboBox {
                    typeFilter: "QtQuick3D.Texture"
                    Layout.fillWidth: true
                    backendValue: backendValues.emissive_texture_texture
                    defaultItem: qsTr("Default")
                }
            }
            Label {
                text: qsTr("MaskTexture")
                tooltip: qsTr("Defines a texture for emissive mask.")
            }
            SecondColumnLayout {
                IdComboBox {
                    typeFilter: "QtQuick3D.Texture"
                    Layout.fillWidth: true
                    backendValue: backendValues.emissive_mask_texture_texture
                    defaultItem: qsTr("Default")
                }
            }
            }
            ColumnLayout {
                width: parent.width
                Label {
                    width: 100
                    text: qsTr("Mask Offset")
                    tooltip: qsTr("Sets the mask offset of emissive map.")
                }

                RowLayout {
                    spacing: materialRoot.labelSpinBoxSpacing
                    width: parent.width

                    Label {
                        text: qsTr("X")
                        width: materialRoot.labelWidth
                        color: StudioTheme.Values.theme3DAxisXColor
                    }
                    SpinBox {
                        maximumValue: 1
                        minimumValue: 0
                        decimals: 2
                        stepSize: 0.1
                        backendValue: backendValues.emissive_mask_offset_x
                        Layout.fillWidth: true
                        Layout.minimumWidth: materialRoot.spinBoxMinimumWidth
                    }
                }
                RowLayout {
                    spacing: materialRoot.labelSpinBoxSpacing

                    Label {
                        text: qsTr("Y")
                        width: materialRoot.labelWidth
                        color: StudioTheme.Values.theme3DAxisYColor
                    }
                    SpinBox {
                        maximumValue: 1
                        minimumValue: 0
                        decimals: 2
                        stepSize: 0.1
                        backendValue: backendValues.emissive_mask_offset_y
                        Layout.fillWidth: true
                        Layout.minimumWidth: materialRoot.spinBoxMinimumWidth
                    }
                }
                RowLayout {
                    spacing: materialRoot.labelSpinBoxSpacing

                    Label {
                        text: qsTr("Z")
                        width: materialRoot.labelWidth
                        color: StudioTheme.Values.theme3DAxisZColor
                    }
                    SpinBox {
                        maximumValue: 1
                        minimumValue: 0
                        decimals: 2
                        stepSize: 0.1
                        backendValue: backendValues.emissive_mask_offset_z
                        Layout.fillWidth: true
                        Layout.minimumWidth: materialRoot.spinBoxMinimumWidth
                    }
                }
            }
        }
    }

    Section {
        caption: qsTr("Emission Color")
        width: parent.width
        ColorEditor {
            caption: qsTr("Emission Color")
            backendValue: backendValues.emission_color
            supportGradient: false
            isVector3D: true
            Layout.fillWidth: true
        }
    }

    Section {
        caption: qsTr("Metal Color")
        width: parent.width
        ColorEditor {
            caption: qsTr("Metal Color")
            backendValue: backendValues.metal_color
            supportGradient: false
            isVector3D: true
            Layout.fillWidth: true
        }
    }

    Section {
        caption: qsTr("Roughness")
        width: parent.width
        SectionLayout {
            Label {
                text: qsTr("Map Offset")
                tooltip: qsTr("Set the material roughness map offset.")
            }
            SecondColumnLayout {
                SpinBox {
                    maximumValue: 1
                    minimumValue: 0
                    decimals: 2
                    stepSize: 0.1
                    backendValue: backendValues.roughness_map_offset
                    Layout.fillWidth: true
                }
            }
            Label {
                text: qsTr("Map scale")
                tooltip: qsTr("Set the material roughness map scale.")
            }
            SecondColumnLayout {
                SpinBox {
                    maximumValue: 1
                    minimumValue: 0
                    decimals: 2
                    stepSize: 0.1
                    backendValue: backendValues.roughness_map_scale
                    Layout.fillWidth: true
                }
            }
            Label {
                text: qsTr("Texture")
                tooltip: qsTr("Defines a texture for roughness map.")
            }
            SecondColumnLayout {
                IdComboBox {
                    typeFilter: "QtQuick3D.Texture"
                    Layout.fillWidth: true
                    backendValue: backendValues.roughness_texture_texture
                    defaultItem: qsTr("Default")
                }
            }
        }
    }
    Section {
        caption: qsTr("Reflection")
        width: parent.width

        ColumnLayout {
            width: parent.width - 16
            SectionLayout {
                Label {
                    text: qsTr("Map Offset")
                    tooltip: qsTr("Set the material reclection map offset.")
                }
                SecondColumnLayout {
                    SpinBox {
                        maximumValue: 1
                        minimumValue: 0
                        decimals: 2
                        stepSize: 0.1
                        backendValue: backendValues.reflection_map_offset
                        Layout.fillWidth: true
                    }
                }
                Label {
                    text: qsTr("Map scale")
                    tooltip: qsTr("Set the material reclection map scale.")
                }
                SecondColumnLayout {
                    SpinBox {
                        maximumValue: 1
                        minimumValue: 0
                        decimals: 2
                        stepSize: 0.1
                        backendValue: backendValues.reflection_map_scale
                        Layout.fillWidth: true
                    }
                }
            Label {
                text: qsTr("Texture")
                tooltip: qsTr("Defines a texture for reflection map.")
            }
            SecondColumnLayout {
                IdComboBox {
                    typeFilter: "QtQuick3D.Texture"
                    Layout.fillWidth: true
                    backendValue: backendValues.reflection_texture_texture
                    defaultItem: qsTr("Default")
                }
            }
            }

            ColumnLayout {
                width: parent.width
                Label {
                    width: 100
                    text: qsTr("Tiling")
                    tooltip: qsTr("Sets the tiling repeat of the reflection map.")
                }

                RowLayout {
                    spacing: materialRoot.labelSpinBoxSpacing

                    Label {
                        text: qsTr("X")
                        width: materialRoot.labelWidth
                        color: StudioTheme.Values.theme3DAxisXColor
                    }
                    SpinBox {
                        maximumValue: 100
                        minimumValue: 1
                        decimals: 0
                        backendValue: backendValues.tiling_x
                        Layout.fillWidth: true
                        Layout.minimumWidth: materialRoot.spinBoxMinimumWidth
                    }
                }
                RowLayout {
                    spacing: materialRoot.labelSpinBoxSpacing

                    Label {
                        text: qsTr("Y")
                        width: materialRoot.labelWidth
                        color: StudioTheme.Values.theme3DAxisYColor
                    }
                    SpinBox {
                        maximumValue: 100
                        minimumValue: 1
                        decimals: 0
                        backendValue: backendValues.tiling_y
                        Layout.fillWidth: true
                        Layout.minimumWidth: materialRoot.spinBoxMinimumWidth
                    }
                }
                RowLayout {
                    spacing: materialRoot.labelSpinBoxSpacing

                    Label {
                        text: qsTr("Z")
                        width: materialRoot.labelWidth
                        color: StudioTheme.Values.theme3DAxisZColor
                    }
                    SpinBox {
                        maximumValue: 100
                        minimumValue: 1
                        decimals: 0
                        backendValue: backendValues.tiling_z
                        Layout.fillWidth: true
                        Layout.minimumWidth: materialRoot.spinBoxMinimumWidth
                    }
                }
            }
        }
    }
    Section {
        caption: qsTr("Bump")
        width: parent.width
        SectionLayout {
            Label {
                text: qsTr("Amount")
                tooltip: qsTr("Set the bump map bumpiness.")
            }
            SecondColumnLayout {
                SpinBox {
                    maximumValue: 2
                    minimumValue: 0
                    decimals: 2
                    stepSize: 0.1
                    backendValue: backendValues.bump_amount
                    Layout.fillWidth: true
                }
            }
            Label {
                text: qsTr("Texture")
                tooltip: qsTr("Defines a texture for bump map.")
            }
            SecondColumnLayout {
                IdComboBox {
                    typeFilter: "QtQuick3D.Texture"
                    Layout.fillWidth: true
                    backendValue: backendValues.bump_texture_texture
                    defaultItem: qsTr("Default")
                }
            }
        }
    }
}
