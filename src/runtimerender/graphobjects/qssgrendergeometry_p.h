/****************************************************************************
**
** Copyright (C) 2019 The Qt Company Ltd.
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

#ifndef QSSG_RENDER_GEOMETRY_H
#define QSSG_RENDER_GEOMETRY_H

//
//  W A R N I N G
//  -------------
//
// This file is not part of the Qt API.  It exists purely as an
// implementation detail.  This header file may change from version to
// version without notice, or even be removed.
//
// We mean it.
//

#include <QtQuick3DRuntimeRender/private/qssgrendergraphobject_p.h>
#include <QtQuick3DRuntimeRender/private/qssgrendernode_p.h>
#include <QtQuick3DRuntimeRender/private/qssgrendermesh_p.h>
#include <QtQuick3DRuntimeRender/private/qssgrendererutil_p.h>
#include <QtQuick3DAssetImport/private/qssgmeshutilities_p.h>

#include <QtCore/qbytearray.h>

QT_BEGIN_NAMESPACE

class Q_QUICK3DRUNTIMERENDER_EXPORT QSSGRenderGeometry : public QSSGRenderGraphObject
{
public:
    enum PrimitiveType { // must match MeshData::PrimitiveType
        Points = 0,
        LineStrip,
        LineLoop,
        Lines,
        TriangleStrip,
        TriangleFan,
        Triangles, // Default primitive type
        Patches
    };

    struct Attribute {
        enum Semantic { // must match MeshData::Attribute::Semantic
            IndexSemantic = 0,
            PositionSemantic,           // attr_pos
            NormalSemantic,             // attr_norm
            TexCoordSemantic,           // attr_uv0
            TangentSemantic,            // attr_textan
            BinormalSemantic,           // attr_binormal
            JointSemantic,              // attr_joints
            WeightSemantic,             // attr_weights
            ColorSemantic,              // attr_color
            TargetPosition0Semantic,    // attr_tpos0
            TargetPosition1Semantic,    // attr_tpos1
            TargetPosition2Semantic,    // attr_tpos2
            TargetPosition3Semantic,    // attr_tpos3
            TargetPosition4Semantic,    // attr_tpos4
            TargetPosition5Semantic,    // attr_tpos5
            TargetPosition6Semantic,    // attr_tpos6
            TargetPosition7Semantic,    // attr_tpos7
            TargetNormal0Semantic,      // attr_tnorm0
            TargetNormal1Semantic,      // attr_tnorm1
            TargetNormal2Semantic,      // attr_tnorm2
            TargetNormal3Semantic,      // attr_tnorm3
            TargetTangent0Semantic,     // attr_ttan0
            TargetTangent1Semantic,     // attr_ttan1
            TargetBinormal0Semantic,    // attr_tbinorm0
            TargetBinormal1Semantic     // attr_tbinorm1
        };
        enum ComponentType { // must match MeshData::Attribute::ComponentType
            U8Type = 0,
            I8Type,
            U16Type,
            I16Type,
            U32Type,
            I32Type,
            U64Type,
            I64Type,
            F16Type,
            F32Type,
            F64Type
        };
        Semantic semantic = PositionSemantic;
        int offset = -1;
        ComponentType componentType = F32Type;
    };

    explicit QSSGRenderGeometry();
    virtual ~QSSGRenderGeometry();

    const QByteArray &vertexBuffer() const;
    QByteArray &vertexBuffer();
    const QByteArray &indexBuffer() const;
    QByteArray &indexBuffer();
    int attributeCount() const;
    Attribute attribute(int idx) const;
    PrimitiveType primitiveType() const;
    QVector3D boundsMin() const;
    QVector3D boundsMax() const;
    int stride() const;

    void setVertexData(const QByteArray &data);
    void setIndexData(const QByteArray &data);
    void setStride(int stride);
    void setBounds(const QVector3D &min, const QVector3D &max);
    void setPrimitiveType(PrimitiveType type);

    void addAttribute(Attribute::Semantic semantic, int offset,
                      Attribute::ComponentType componentType);
    void addAttribute(const Attribute &att);

    void clear();
    void clearAttributes();

    QSSGRenderMesh *createOrUpdate(const QSSGRef<QSSGBufferManager> &bufferManager);

protected:
    Q_DISABLE_COPY(QSSGRenderGeometry)

    bool m_dirty = true;
    QSSGMeshUtilities::MeshData m_meshData;
    QSSGRef<QSSGMeshUtilities::QSSGMeshBuilder> m_meshBuilder;
    QSSGBounds3 m_bounds;
};

QT_END_NAMESPACE

#endif // QSSG_GEOMETRY_H
