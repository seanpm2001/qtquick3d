/****************************************************************************
**
** Copyright (C) 2019 The Qt Company Ltd.
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

import QtQuick 2.14
import QtQuick3D 1.0

Item {
    Component.onCompleted: {
        console.log("Keys:\n[L] - toggle lighting\n[N] - add a new point light\n[R] - remove a point light\n[T] - toggle directional light");
    }

    id: root

    Text {
        color: "#ffffff"
        style: Text.Outline
        styleColor: "#606060"
        font.pixelSize: 28
        property int api: GraphicsInfo.api
        text: {
            if (GraphicsInfo.api === GraphicsInfo.OpenGL)
                "OpenGL";
            else if (GraphicsInfo.api === GraphicsInfo.Software)
                "Software";
            else if (GraphicsInfo.api === GraphicsInfo.Direct3D12)
                "D3D12";
            else if (GraphicsInfo.api === GraphicsInfo.OpenVG)
                "OpenVG";
            else if (GraphicsInfo.api === GraphicsInfo.OpenGLRhi)
                "OpenGL via QRhi";
            else if (GraphicsInfo.api === GraphicsInfo.Direct3D11Rhi)
                "D3D11 via QRhi";
            else if (GraphicsInfo.api === GraphicsInfo.VulkanRhi)
                "Vulkan via QRhi";
            else if (GraphicsInfo.api === GraphicsInfo.MetalRhi)
                "Metal via QRhi";
            else if (GraphicsInfo.api === GraphicsInfo.Null)
                "Null via QRhi";
            else
                "Unknown API";
        }
    }

    Image {
        source: "qt_logo.png"
        x: 50
        NumberAnimation on y { from: 50; to: 400; duration: 3000; loops: -1 }
    }

    property bool useLighting: false;
    property var lights: []

    focus: true
    Keys.onPressed: {
        if (event.key === Qt.Key_L) {
            useLighting = !useLighting;
        } else if (event.key === Qt.Key_N && lights.length + 2 <= 7) {
            var colors = [ "yellow", "red", "green", "blue", "purple", "magenta" ];
            var lightColor = colors[lights.length];
            console.log("Adding new point light: " + (lights.length + 1) + " color: " + lightColor);
            var component = Qt.createComponent("qrc:/SomePointLight.qml");
            var newLight = component.createObject(pointLightContainer, { color: lightColor });
            lights.push(newLight);
        } else if (event.key === Qt.Key_R && lights.length > 0) {
            console.log("Removing last point light. Remaining: " + (lights.length - 1));
            var dyingLight = lights.pop();
            dyingLight.destroy();
        } else if (event.key === Qt.Key_T) {
            console.log("Toggling visibility of directional light: " + !dirLight.visible);
            dirLight.visible = !dirLight.visible
        }
    }

    View3D {
        id: v3d
        anchors.fill: parent
        camera: camera
        renderMode: View3D.Overlay

        environment: SceneEnvironment {
            depthPrePassEnabled: true
        }

        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(0, 200, -300)
            rotation: Qt.vector3d(30, 0, 0)
        }
        Model {
            position: Qt.vector3d(0, 0, 0)
            source: "#Cube"
            materials: [ DefaultMaterial {
                    lighting: root.useLighting ? DefaultMaterial.FragmentLighting : DefaultMaterial.NoLighting
                } ]
            rotation: Qt.vector3d(0, 90, 0)

            PropertyAnimation on rotation { from: Qt.vector3d(0, 0, 0); to: Qt.vector3d(0, 360, 0); duration: 5000; loops: -1 }
        }
        Model {
            source: "teapot.mesh"
            x: 100
            y: 100
            scale: Qt.vector3d(15, 15, 15)
            materials: [ DefaultMaterial {
                    lighting: root.useLighting ? DefaultMaterial.FragmentLighting : DefaultMaterial.NoLighting
                    diffuseColor: "salmon"
                } ]
            PropertyAnimation on rotation { from: Qt.vector3d(0, 0, 0); to: Qt.vector3d(0, -360, 360); duration: 2000; loops: -1 }
        }
        DirectionalLight {
            id: dirLight
            ambientColor: Qt.rgba(0.1, 0.1, 0.1, 1.0);
        }
        Node {
            id: pointLightContainer
        }
    }
}
