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
        caption: qsTr("Transmission")
        width: parent.width
        SectionLayout {
            Label {
                text: qsTr("Transmission Weight")
                tooltip: qsTr("Set the material transmission weight.")
            }
            SecondColumnLayout {
                SpinBox {
                    maximumValue: 1
                    minimumValue: 0
                    decimals: 2
                    stepSize: 0.1
                    backendValue: backendValues.transmission_weight
                    Layout.fillWidth: true
                }
            }
            Label {
                text: qsTr("Reflection Weight")
                tooltip: qsTr("Set the material reflection weight.")
            }
            SecondColumnLayout {
                SpinBox {
                    maximumValue: 1
                    minimumValue: 0
                    decimals: 2
                    stepSize: 0.1
                    backendValue: backendValues.reflection_weight
                    Layout.fillWidth: true
                }
            }
            Label {
                text: qsTr("Texture")
                tooltip: qsTr("Defines a texture for transmission map.")
            }
            SecondColumnLayout {
                IdComboBox {
                    typeFilter: "QtQuick3D.Texture"
                    Layout.fillWidth: true
                    backendValue: backendValues.transmission_texture_texture
                    defaultItem: qsTr("Default")
                }
            }
        }
    }
    Section {
        caption: qsTr("General")
        width: parent.width

        ColumnLayout {
            width: parent.width - 16
            SectionLayout {
                Label {
                    text: qsTr("Translucency Falloff")
                    tooltip: qsTr("Set the falloff of the translucency of the material.")
                }
                SecondColumnLayout {
                    SpinBox {
                        maximumValue: 100
                        minimumValue: 0
                        decimals: 2
                        backendValue: backendValues.uTranslucentFalloff
                        Layout.fillWidth: true
                    }
                }
                Label {
                    text: qsTr("Opacity")
                    tooltip: qsTr("Set the opacity of the material.")
                }
                SecondColumnLayout {
                    SpinBox {
                        maximumValue: 100
                        minimumValue: 0
                        decimals: 2
                        backendValue: backendValues.uOpacity
                        Layout.fillWidth: true
                    }
                }
            }

            ColumnLayout {
                width: parent.width
                Label {
                    width: 100
                    text: qsTr("Texture Tiling")
                    tooltip: qsTr("Sets the tiling repeat of the reflection map.")
                }

                RowLayout {
                    spacing: materialRoot.labelSpinBoxSpacing

                    Label {
                        text: qsTr("X")
                        width: materialRoot.labelWidth
                    }
                    SpinBox {
                        maximumValue: 100
                        minimumValue: 1
                        decimals: 0
                        backendValue: backendValues.texture_tiling_x
                        Layout.fillWidth: true
                        Layout.minimumWidth: materialRoot.spinBoxMinimumWidth
                    }
                }
                RowLayout {
                    spacing: materialRoot.labelSpinBoxSpacing

                    Label {
                        text: qsTr("Y")
                        width: materialRoot.labelWidth
                    }
                    SpinBox {
                        maximumValue: 100
                        minimumValue: 1
                        decimals: 0
                        backendValue: backendValues.texture_tiling_y
                        Layout.fillWidth: true
                        Layout.minimumWidth: materialRoot.spinBoxMinimumWidth
                    }
                }
            }
        }
    }
    Section {
        caption: qsTr("Diffuse Map")
        width: parent.width
        SectionLayout {
            Label {
                text: qsTr("Light Wrap")
                tooltip: qsTr("Set the diffuse light bend of the material.")
            }
            SecondColumnLayout {
                SpinBox {
                    maximumValue: 1
                    minimumValue: 0
                    decimals: 2
                    stepSize: 0.1
                    backendValue: backendValues.uDiffuseLightWrap
                    Layout.fillWidth: true
                }
            }
            Label {
                text: qsTr("Texture")
                tooltip: qsTr("Defines a texture for diffuse map.")
            }
            SecondColumnLayout {
                IdComboBox {
                    typeFilter: "QtQuick3D.Texture"
                    Layout.fillWidth: true
                    backendValue: backendValues.diffuse_texture_texture
                    defaultItem: qsTr("Default")
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
