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
import QtQuick3D 1.15
import QtQuick3D.Effects 1.15

Effect {
    readonly property TextureInput sprite: TextureInput {
        texture: Texture {}
    }

    Shader {
        id: rgbl
        stage: Shader.Fragment
        shader: "shaders/fxaaRgbl.frag"
    }
    Shader {
        id: blur
        stage: Shader.Fragment
        shader: "shaders/fxaaBlur.frag"
    }
    Buffer {
        id: rgblBuffer
        name: "rgbl_buffer"
        format: Buffer.RGBA8
        textureFilterOperation: Buffer.Linear
        textureCoordOperation: Buffer.ClampToEdge
        bufferFlags: Buffer.None // aka frame
    }

    passes: [
        Pass {
            shaders: rgbl
            output: rgblBuffer
        },
        Pass {
            shaders: blur
            commands: [ BufferInput {
                    buffer: rgblBuffer
                }, BufferInput {
                    param: "sprite"
                }
            ]
        }
    ]
}
