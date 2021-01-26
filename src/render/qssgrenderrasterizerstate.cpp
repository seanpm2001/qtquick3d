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

#include <QtQuick3DRender/private/qssgrendercontext_p.h>
#include <QtQuick3DRender/private/qssgrenderrasterizerstate_p.h>

QT_BEGIN_NAMESPACE

QSSGRenderRasterizerState::QSSGRenderRasterizerState(const QSSGRef<QSSGRenderContext> &context,
                                                     float depthBias,
                                                     float depthScale)
    : m_backend(context->backend())
{
    // create backend handle
    m_handle = m_backend->createRasterizerState(depthBias, depthScale);
}

QSSGRenderRasterizerState::~QSSGRenderRasterizerState()
{
    if (m_handle)
        m_backend->releaseRasterizerState(m_handle);
}

QT_END_NAMESPACE
