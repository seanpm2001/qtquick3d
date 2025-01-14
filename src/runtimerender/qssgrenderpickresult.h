// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#ifndef QSSGRENDERPICKRESULT_H
#define QSSGRENDERPICKRESULT_H

#include <QtQuick3DRuntimeRender/qtquick3druntimerenderexports.h>

#include <QtGui/qvectornd.h>

#include <limits>

QT_BEGIN_NAMESPACE

class QSSGRenderGraphObject;

class QSSGRenderPickResult
{
public:
    const QSSGRenderGraphObject *m_hitObject = nullptr;
    float m_distanceSq = std::numeric_limits<float>::max();
    // The local coordinates in X,Y UV space where the hit occurred
    QVector2D m_localUVCoords;
    // The position in world coordinates
    QVector3D m_scenePosition;
    // The position in local coordinates
    QVector3D m_localPosition;
    // The normal of the hit face
    QVector3D m_faceNormal;
    // The subset index
    int m_subset = 0;
    int m_instanceIndex = -1;
};

Q_STATIC_ASSERT(std::is_trivially_destructible_v<QSSGRenderPickResult>);

QT_END_NAMESPACE

#endif // QSSGRENDERPICKRESULT_H
