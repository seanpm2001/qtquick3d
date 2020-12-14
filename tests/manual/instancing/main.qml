/****************************************************************************
**
** Copyright (C) 2020 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick
import QtQuick3D
import QtQuick3D.Helpers

import InstancingTest

Window {
    visible: true
    width: 1280
    height: 720
    title: qsTr("Instanced Rendering")

    View3D {
        id: viewport
        anchors.fill: parent

        Node {
            PerspectiveCamera {
                z: 1000
                SequentialAnimation  on z {
                    running: false
                    loops: -1
                    PauseAnimation {
                        duration: 4000
                    }
                    NumberAnimation {
                        from: 5000
                        to: 0
                        duration: 15000
                    }
                    PauseAnimation {
                        duration: 300
                    }
                    NumberAnimation {
                        from: 0
                        to: 5000
                        duration: 5000
                    }
                }
            }

            PropertyAnimation on eulerRotation.y {
                from: 0
                to: 360
                running: false
                duration: 17000
                loops: -1
            }
        }

        DirectionalLight {
            ambientColor: "#777777"
        }

        CustomInstancing {
            id: customInstancing
            instanceCount: 121
        }

        Model {
            id: transparentModel
            source: "#Cube"
            instancing: customInstancing

            materials: DefaultMaterial {
                diffuseColor: "lightgray"
                opacity: 0.6
            }
        }

        RandomInstancing {
            id: randomWithData
            instanceCount: 350

            position: InstanceRange {
                from: Qt.vector3d(-500, -400, -500)
                to: Qt.vector3d(500, 400, 500)
            }
            scale: InstanceRange {
                from: Qt.vector3d(0.2, 0.2, 0.2)
                to: Qt.vector3d(1.0, 1.0, 1.0)
                proportional: true
            }
            rotation: InstanceRange {
                from: Qt.vector3d(0, 0, 0)
                to: Qt.vector3d(360, 360, 360)
            }
            color: InstanceRange {
                from: Qt.rgba(0.1, 0.1, 0.1, 1.0)
                to: Qt.rgba(1, 1, 1, 1.0)
            }
            // instancedMaterial custom data:  METALNESS, ROUGHNESS, FRESNEL_POWER, SPECULAR_AMOUNT
            customData: InstanceRange {
                from: Qt.vector4d(0, 0, 0, 0)
                to: Qt.vector4d(1, 1, 5, 1)
            }

            NumberAnimation on instanceCountOverride {
                from: 1
                to: randomWithData.instanceCount
                duration: 5000
            }
        }

        CustomMaterial {
            id: instancedMaterial
            shadingMode: CustomMaterial.Shaded
            fragmentShader: "material.frag"
            vertexShader: "material.vert"
            property color uDiffuse: "lightgray"
        }

        Model {
            id: cubeModel
            source: "#Cube"
            instancing: randomWithData

            materials: DefaultMaterial {
                diffuseColor: "white"
            }

            PropertyAnimation on eulerRotation.x {
                from: 0
                to: 360
                duration: 5000
                loops: -1
            }
            Model {
                id: sphereModel
                source: "#Sphere"
                instancing: parent.instancing

                property real scaleFactor: 0.5
                scale: Qt.vector3d(scaleFactor, scaleFactor, scaleFactor);
                position: Qt.vector3d(-50, -50, -50)
                materials: instancedMaterial
                SequentialAnimation on scaleFactor {
                    PauseAnimation {duration: 3000}
                    NumberAnimation {from: 0.5; to: 1.5; duration: 200}
                    NumberAnimation {from: 1.5; to: 0.5; duration: 200}
                    loops: -1
                }
            } // sphereModel
        } // cubeModel
    }
    DebugView {
        source: viewport
        anchors.top: parent.top
        anchors.left: parent.left
    }
}
