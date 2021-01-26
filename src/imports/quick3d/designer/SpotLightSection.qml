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
    width: parent.width

    Section {
        caption: qsTr("SpotLight")
        width: parent.width

        SectionLayout {
            Label {
                text: qsTr("Scope")
                tooltip: qsTr("Sets the scope of the light. Only the node and its children are affected by this light.")
            }
            SecondColumnLayout {
                IdComboBox {
                    typeFilter: "QtQuick3D.Node"
                    Layout.fillWidth: true
                    backendValue: backendValues.scope
                }
            }
            Label {
                text: qsTr("Brightness")
                tooltip: qsTr("Sets the strength of the light.")
            }
            SecondColumnLayout {
                SpinBox {
                    maximumValue: 9999999
                    minimumValue: -9999999
                    realDragRange: 5000
                    decimals: 0
                    backendValue: backendValues.brightness
                    Layout.fillWidth: true
                }
            }

            Label {
                text: qsTr("Constant Fade")
                tooltip: qsTr("Sets the constant attenuation of the light.")
            }
            SecondColumnLayout {
                SpinBox {
                    minimumValue: 0
                    maximumValue: 10
                    decimals: 2
                    stepSize: 0.1
                    backendValue: backendValues.constantFade
                    Layout.fillWidth: true
                }
            }

            Label {
                text: qsTr("Linear Fade")
                tooltip: qsTr("Sets the linear attenuation of the light.")
            }
            SecondColumnLayout {
                SpinBox {
                    minimumValue: 0
                    maximumValue: 10
                    decimals: 2
                    stepSize: 0.1
                    backendValue: backendValues.linearFade
                    Layout.fillWidth: true
                }
            }

            Label {
                text: qsTr("Quadratic Fade")
                tooltip: qsTr("Sets the quadratic attenuation of the light.")
            }
            SecondColumnLayout {
                SpinBox {
                    minimumValue: 0
                    maximumValue: 10
                    decimals: 2
                    stepSize: 0.1
                    backendValue: backendValues.quadraticFade
                    Layout.fillWidth: true
                }
            }

            Label {
                text: qsTr("Cone Angle")
                tooltip: qsTr("Sets the angle of the light cone.")
            }
            SecondColumnLayout {
                SpinBox {
                    minimumValue: 0
                    maximumValue: 180
                    decimals: 2
                    backendValue: backendValues.coneAngle
                    Layout.fillWidth: true
                }
            }

            Label {
                text: qsTr("Inner Cone Angle")
                tooltip: qsTr("Sets the angle of the inner light cone.")
            }
            SecondColumnLayout {
                SpinBox {
                    minimumValue: 0
                    maximumValue: 180
                    decimals: 2
                    backendValue: backendValues.innerConeAngle
                    Layout.fillWidth: true
                }
            }
        }
    }

    Section {
        caption: qsTr("Color")
        width: parent.width

        ColorEditor {
            caption: qsTr("Color")
            backendValue: backendValues.color
            supportGradient: false
            Layout.fillWidth: true
        }
    }

    Section {
        caption: qsTr("Ambient Color")
        width: parent.width
        ColorEditor {
            caption: qsTr("Ambient Color")
            backendValue: backendValues.ambientColor
            supportGradient: false
            Layout.fillWidth: true
        }
    }

    ShadowSection {
        width: parent.width
    }

}
