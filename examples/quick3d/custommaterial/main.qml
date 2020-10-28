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
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: window
    width: 1280
    height: 720
    visible: true
    title: "Custom Materials Example"

    View3D {
        id: v3d
        anchors.fill: parent

        camera: camera

        environment: SceneEnvironment {
            backgroundMode: SceneEnvironment.SkyBox
            probeExposure: 2
            lightProbe: Texture {
                source: "maps/OpenfootageNET_lowerAustria01-1024.hdr"
            }
        }

        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(0, 100, 700)
        }

        SpotLight {
            position: Qt.vector3d(0, 500, 0)
            eulerRotation.x: -60
            color: Qt.rgba(1.0, 1.0, 0.1, 1.0)
            brightness: 50
            castsShadow: true
            shadowMapQuality: Light.ShadowMapQualityHigh
        }

        property real globalRotation: 0
        NumberAnimation on globalRotation {
            from: 0
            to: 360
            duration: 15000
            loops: Animation.Infinite
        }

        property real radius: 400
        property real separation: 360/6

        Model {
            id: floor
            source: "#Rectangle"
            y: -200
            scale: Qt.vector3d(15, 15, 1)
            eulerRotation.x: -90
            materials: [
                DefaultMaterial {
                    diffuseColor: "white"
                }
            ]
        }

        // Start with a simple material, using the built-in implementation for everything.
        Node {
            eulerRotation.y: v3d.globalRotation
            WeirdShape {
                x: v3d.radius
                customMaterial: CustomMaterial {
                    shadingMode: CustomMaterial.Shaded
                    fragmentShader: "material_default.frag"
                    property color uDiffuse: "fuchsia"
                    property real uSpecular: 1.0
                }
            }
        }

        // A metallic material using defaults for everything, except ambient light, and no uniforms.
        Node {
            eulerRotation.y: v3d.globalRotation + v3d.separation * 1
            WeirdShape {
                x: v3d.radius
                customMaterial: CustomMaterial {
                    shadingMode: CustomMaterial.Shaded
                    fragmentShader: "material_lightprobe.frag"
                }
            }
        }

        // A material with custom handling of all the lights, but still using
        // the built-in specular function.
        Node {
            eulerRotation.y: v3d.globalRotation + v3d.separation * 2
            WeirdShape {
                x: v3d.radius
                customMaterial: CustomMaterial {
                    shadingMode: CustomMaterial.Shaded
                    fragmentShader: "material_builtinspecular.frag"
                    property color uDiffuse: "orange"
                    property real uShininess: 150
                }
            }
        }

        // Custom handling of everything, including specular.
        Node {
            eulerRotation.y: v3d.globalRotation  + v3d.separation * 3
            WeirdShape {
                x: v3d.radius
                customMaterial: CustomMaterial {
                    shadingMode: CustomMaterial.Shaded
                    fragmentShader: "material.frag"
                    property color uDiffuse: "green"
                    property real uShininess: 150
                }
            }
        }



        // Same fragment shader, plus custom vertex shader
        Node {
            eulerRotation.y: v3d.globalRotation + v3d.separation * 4
            WeirdShape {
                x: v3d.radius
                customMaterial: CustomMaterial {
                    shadingMode: CustomMaterial.Shaded
                    vertexShader: "material.vert"
                    fragmentShader: "material.frag"
                    property real uTime: 0.0
                    property real uAmplitude: 0.3
                    property color uDiffuse: "yellow"
                    property real uShininess: 50
                    NumberAnimation on uTime { from: 0.0; to: 31.4; duration: 10000; loops: -1 }
                }
            }
        }

        // Material that processes the scene behind the item, giving a see-through effect.
        Node {
            eulerRotation.y: v3d.globalRotation + v3d.separation * 5
            Model {
                id: screenSphere
                source: "#Sphere"
                scale: Qt.vector3d(3, 3, 3)
                x: v3d.radius
                materials: [
                    CustomMaterial {
                        shadingMode: CustomMaterial.Shaded
                        sourceBlend: uKeepAlpha ? CustomMaterial.SrcAlpha : CustomMaterial.NoBlend
                        destinationBlend: uKeepAlpha ? CustomMaterial.OneMinusSrcAlpha : CustomMaterial.NoBlend
                        fragmentShader: "screen.frag"
                        property bool uKeepAlpha: false
                    }
                ]
            }
        }
    }
}
