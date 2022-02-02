/****************************************************************************
**
** Copyright (C) 2022 The Qt Company Ltd.
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
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D

ScrollView {
    id: rootView
    required property PrincipledMaterial targetMaterial
    required property View3D view3D
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    width: availableWidth

    ColumnLayout {
        width: rootView.availableWidth
        MarkdownLabel {
            text: "# Material Details
This section describes a series of properties to add additional details to
a material. Not every material will need all of these properties, but for
specific use cases these details may be exactly what you need.
## Normal
The Normal describes the direction a surface is facing. Each vertex of a Model
also profiles a normal value to define how each face should be shaded. At this
level though the amount of detail a material can provide is limited to the source
mesh's level of detail. Using more detailed meshes can be very expensive, so
instead a Normal Map texture can be provided to add additional surface details
without increasing geometry.
### Normal Map
A Normal map is a special kind of texture where directions (normals) are stored
as color values. These directions are sampled from the Normal map by the material
and combined with the directions of a models geometry to adjust the way light
interacts with the material.
"
        }
        TextureSourceControl {
            defaultTexture: "maps/metallic/normal.jpg"
            defaultClearColor: Qt.rgba(0.5, 0.5, 1.0, 1.0)
            stampMode: true
            stampSource: "maps/normal_stamp.png"
            onTargetTextureChanged: {
                targetMaterial.normalMap = targetTexture
            }
        }
        MarkdownLabel {
            text: "### Normal Strength
By adjusting the normal strength you will see that the amount of influence the
normal map has on the material changes."
        }
        RowLayout {
            Label {
                text: "Normal Strength (" + targetMaterial.normalStrength.toFixed(2) + ")"
                Layout.fillWidth: true
            }
            Slider {
                from: 0
                to: 1
                value: targetMaterial.normalStrength
                onValueChanged: targetMaterial.normalStrength = value
            }
        }

        VerticalSectionSeparator {}

        MarkdownLabel {
            text: "## Height
In addition to providing a Normal map to give the impression of more geometry
it is possible to also provide a height map for give even more depth to a
material. This can also be known as a displacement map. Normally there are two
approaches to displacement: Tessellation and Parallax Occlusion Mapping. The
PrincipledMaterial currently only supports Parallax Occlusion Mapping which
means that instead of adding additional geometry based the height map, instead
we manipulate the way textures are mapped to the geometry to give the illusion
of more depth. And while this approach is much cheaper than Tessellation, it
comes with the limitation that it really only works for flat surfaces, and does
not change the silhouette of a model (how it looks from the side).

So for our example, any height map you add will only have the desired effect on
the Cube, and only if other textures are present.
### Height Amount
This is the amount of displacement that should be applied from the height map.
Unlike many of the other fields, it is unlikely that you will want to just set
this value to 1.0 (the max).  The amount of displacement needed for a particular
material will require some adjustment for taste.  A little bit goes a long way."
        }
        RowLayout {
            Label {
                text: "Height Amount  (" + targetMaterial.heightAmount.toFixed(2) + ")"
                Layout.fillWidth: true
            }
            Slider {
                from: 0
                to: 1
                value: targetMaterial.heightAmount
                onValueChanged: targetMaterial.heightAmount = value
            }
        }

        MarkdownLabel {
            text: "### Height Map
The Height Map is a greyscale (single channel) texture representing to amount
of displacement that should be applied. A black value (0.0) means none, and
white (1.0) means the maximum amount, which is determined by the Height Amount
property.
"
        }
        ComboBox {
            id: heightChannelComboBox
            textRole: "text"
            valueRole: "value"
            implicitContentWidthPolicy: ComboBox.WidestText
            onActivated: targetMaterial.heightChannel = currentValue
            Component.onCompleted: currentIndex = indexOfValue(targetMaterial.heightChannel)
            model: [
                { value: PrincipledMaterial.R, text: "Red Channel"},
                { value: PrincipledMaterial.G, text: "Green Channel"},
                { value: PrincipledMaterial.B, text: "Blue Channel"},
                { value: PrincipledMaterial.A, text: "Alpha Channel"}
            ]
        }
        TextureSourceControl {
            defaultTexture: "maps/noise.png"
            defaultClearColor: "black"
            onTargetTextureChanged: {
                targetMaterial.heightMap = targetTexture
            }
        }

        VerticalSectionSeparator {}

        MarkdownLabel {
            text: "## Ambient Occlusion
To understand Ambient Occlusion, you must first understand occlusion. Occlusion is
about blocking light, or shadowing. If something is occluded it will be unable
to receive light, and will appear darker than parts that are un-occluded.
But this simplistic occlusion of light only takes into consideration the first reflection
of a light on a model. Light will be reflected off surfaces to other surrounding
surfaces multiple times. This distinction between the first reflection vs any additional
reflections is referred to as direct vs indirect light. Ambient Occlusion is about
simulating a behavior of indirect light: when a model has crevasses or corners,
light is less likely to be reflected into them, leading them to be darker than more
open faces. Realtime renderers like Qt Quick 3D don't tend to model more than the first
reflection of light (direct lighting) so baking an ambient occlusion map will provide
additional realism to materials.
"
        }
        MarkdownLabel {
            text: "### Ambient Occlusion Map
Ambient Occlusion maps are baked in 3D content creation tools for each model
using ray tracing. Since all three of our models share the same material, if
an appropriate map is applied, it will only look correct for one of the models
at a time.  In this case the only model we have to would benefit from an AO map
is the monkey, since it is the only one with any details that could self occlude.
If you apply the provided texture you will notice the crevasses around the eyes
and ears of the monkey model will appear slightly darker.
"
        }
        ComboBox {
            id: aoChannelComboBox
            textRole: "text"
            valueRole: "value"
            implicitContentWidthPolicy: ComboBox.WidestText
            onActivated: targetMaterial.occlusionChannel = currentValue
            Component.onCompleted: currentIndex = indexOfValue(targetMaterial.occlusionChannel)
            model: [
                { value: PrincipledMaterial.R, text: "Red Channel"},
                { value: PrincipledMaterial.G, text: "Green Channel"},
                { value: PrincipledMaterial.B, text: "Blue Channel"},
                { value: PrincipledMaterial.A, text: "Alpha Channel"}
            ]
        }

        TextureSourceControl {
            defaultTexture: "maps/monkey_ao.jpg"
            defaultClearColor: "white"
            onTargetTextureChanged: {
                targetMaterial.occlusionMap = targetTexture
            }
        }

        VerticalSectionSeparator {}

        MarkdownLabel {
            text: "## Emission
The emission properties are about the material's ability to produce its own
light. This light does not affect other materials in the scene, but does add
energy to the lighting calculations of the material without them coming from
an external source."
        }

        MarkdownLabel {
            text: "### Emissive Factor
In the absence of an Emissive Map, the amount of light a material emits is
controlled by the Emissive Factor. Each channel is added as an additional
light contribution to the material. So if you set the value of Red to 1.0, then
1.0 of red light will be added to the material's color after all other lighting
calculations have been done. These 3 channels are representing the amount of
each color that is added, but the property itself is not a color. That is
because colors are always clamped to values between 0.0 - 1.0, whereas these
factors can be any floating point values. In this example these values are clamped
between 0.0 and 1.0, but you can click the *Un-Clamp* button to experiment with
values between -1.0 and 2.0. The scene should also look slightly different
because some post processing effects are enabled to demonstrate handling color
values greater than 1.0."
        }

        RowLayout {
            Button {
                id: clampEmissionButton
                property bool clampEmission: true
                text: clampEmission ? "Un-clamp" : "Clamp"
                checkable: true
                checked: clampEmission
                onClicked: {
                    clampEmission = !clampEmission
                    if (clampEmission) {
                        rootView.view3D.environment.tonemapMode = SceneEnvironment.TonemapModeLinear
                        rootView.view3D.environment.enableEffects = false;
                    } else {
                        rootView.view3D.environment.tonemapMode = SceneEnvironment.TonemapModeNone
                        rootView.view3D.environment.enableEffects = true;
                    }
                }
            }
            Button {
                text: "All 0.0"
                onClicked: {
                    targetMaterial.emissiveFactor = Qt.vector3d(0, 0, 0)
                }
            }
            Button {
                text: "All 1.0"
                onClicked: {
                    targetMaterial.emissiveFactor = Qt.vector3d(1, 1, 1)
                }
            }
        }

        RowLayout {
            Label {
                text: "Red (" + targetMaterial.emissiveFactor.x.toFixed(2) + ")"
                Layout.fillWidth: true
            }
            Slider {
                from: clampEmissionButton.clampEmission ? 0.0 : -1.0
                to: clampEmissionButton.clampEmission ? 1.0 : 2
                value: targetMaterial.emissiveFactor.x
                onValueChanged: targetMaterial.emissiveFactor.x = value
            }
        }
        RowLayout {
            Label {
                text: "Green (" + targetMaterial.emissiveFactor.y.toFixed(2) + ")"
                Layout.fillWidth: true
            }

            Slider {
                from: clampEmissionButton.clampEmission ? 0.0 : -1.0
                to: clampEmissionButton.clampEmission ? 1.0 : 2
                value: targetMaterial.emissiveFactor.y
                onValueChanged: targetMaterial.emissiveFactor.y = value
            }
        }
        RowLayout {
            Label {
                text: "Blue (" + targetMaterial.emissiveFactor.z.toFixed(2) + ")"
                Layout.fillWidth: true
            }

            Slider {
                from: clampEmissionButton.clampEmission ? 0.0 : -1.0
                to: clampEmissionButton.clampEmission ? 1.0 : 2
                value: targetMaterial.emissiveFactor.z
                onValueChanged: targetMaterial.emissiveFactor.z = value
            }
        }
        MarkdownLabel {
            text: "### Emissive Map
If an Emissive Map is provided, then then the Emissive Factor is used as a
multiplier for the color values read from the Emissive Map.  This multiplied
value is then added to the materials color value after all other lighting calculations
have been preformed."
        }
        TextureSourceControl {
            defaultTexture: "maps/monkey_ao.jpg"
            defaultClearColor: "black"
            onTargetTextureChanged: {
                targetMaterial.emissiveMap = targetTexture
            }
        }
    }
}
