/****************************************************************************
**
** Copyright (C) 2020 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of Qt Quick 3D.
**
** $QT_BEGIN_LICENSE:GPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 or (at your option) any later version
** approved by the KDE Free Qt Foundation. The licenses are as published by
** the Free Software Foundation and appearing in the file LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick
import QtQuick3D
import QtQuick3D.Effects

Effect {
    readonly property TextureInput sourceSampler: TextureInput {
        texture: Texture {}
    }
    property real focusDistance: 600
    property real focusRange: 100
    property real blurAmount: 4

    Shader {
        id: downsampleVert
        stage: Shader.Vertex
        shader: "qrc:/qtquick3deffects/shaders/downsample.vert"
    }
    Shader {
        id: downsampleFrag
        stage: Shader.Fragment
        shader: "qrc:/qtquick3deffects/shaders/downsample.frag"
    }

    Shader {
        id: blurVert
        stage: Shader.Vertex
        shader: "qrc:/qtquick3deffects/shaders/depthoffieldblur.vert"
    }
    Shader {
        id: blurFrag
        stage: Shader.Fragment
        shader: "qrc:/qtquick3deffects/shaders/depthoffieldblur.frag"
    }

    Buffer {
        id: downsampleBuffer
        name: "downsampleBuffer"
        format: Buffer.RGBA8
        textureFilterOperation: Buffer.Linear
        textureCoordOperation: Buffer.ClampToEdge
        sizeMultiplier: 0.5
    }

    passes: [
        Pass {
            shaders: [ downsampleVert, downsampleFrag ]
            output: downsampleBuffer
        },
        Pass {
            shaders: [ blurVert, blurFrag ]
            commands: [
                // INPUT is the texture for downsampleBuffer
                BufferInput {
                    buffer: downsampleBuffer
                },
                // the actual input texture is exposed as sourceSampler
                BufferInput {
                    param: "sourceSampler"
                }
            ]
        }
    ]
}
