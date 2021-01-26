/****************************************************************************
**
** Copyright (C) 2008-2012 NVIDIA Corporation.
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

#ifndef QSSG_RENDERER_UTIL_H
#define QSSG_RENDERER_UTIL_H

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

#include <QtQuick3DRender/private/qssgrenderbasetypes_p.h>

QT_BEGIN_NAMESPACE

class QSSGResourceManager;
class QSSGResourceTexture2D;
class QSSGRenderContext;

class QSSGRendererUtil
{
    static const qint16 MAX_SSAA_DIM = 8192; // max render traget size for SSAA mode

public:
    static void resolveMutisampleFBOColorOnly(const QSSGRef<QSSGResourceManager> &inManager,
                                              QSSGResourceTexture2D &ioResult,
                                              QSSGRenderContext &inRenderContext,
                                              qint32 inWidth,
                                              qint32 inHeight,
                                              QSSGRenderTextureFormat inColorFormat,
                                              const QSSGRef<QSSGRenderFrameBuffer> &inSourceFBO);

    static void resolveSSAAFBOColorOnly(const QSSGRef<QSSGResourceManager> &inManager,
                                        QSSGResourceTexture2D &ioResult,
                                        qint32 outWidth,
                                        qint32 outHeight,
                                        QSSGRenderContext &inRenderContext,
                                        qint32 inWidth,
                                        qint32 inHeight,
                                        QSSGRenderTextureFormat inColorFormat,
                                        const QSSGRef<QSSGRenderFrameBuffer> &inSourceFBO);

    static void getSSAARenderSize(qint32 inWidth, qint32 inHeight, qint32 &outWidth, qint32 &outHeight);

    static quint32 nextMultipleOf4(quint32 value) {
        return (value + 3) & ~3;
    }
};
QT_END_NAMESPACE

#endif
