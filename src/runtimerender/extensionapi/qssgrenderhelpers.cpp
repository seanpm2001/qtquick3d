// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#include "qssgrendercontextcore.h"
#include "qssgrenderhelpers.h"

#include <QtQuick3DRuntimeRender/private/qssgrenderer_p.h>
#include <QtQuick3DRuntimeRender/private/qssgrenderhelpers_p.h>
#include <QtQuick3DRuntimeRender/private/qssglayerrenderdata_p.h>

#include <QtQuick3DRuntimeRender/private/qssgrendercamera_p.h>

#include <QtQuick3DUtils/private/qssgassert_p.h>

QT_BEGIN_NAMESPACE

void QSSGRenderHelpers::rhiPrepareRenderable(QSSGRhiContext &rhiCtx,
                                             QSSGPassKey passKey,
                                             const QSSGFrameData &frameData,
                                             QSSGRenderableObject &inObject,
                                             QRhiRenderPassDescriptor *renderPassDescriptor,
                                             QSSGRhiGraphicsPipelineState *ps,
                                             int samples)
{
    auto *layerData = frameData.getCurrent();
    QSSG_ASSERT(layerData, return);
    RenderHelpers::rhiPrepareRenderable(&rhiCtx,
                                        passKey,
                                        *layerData,
                                        inObject,
                                        renderPassDescriptor,
                                        ps,
                                        layerData->getShaderFeatures(),
                                        samples);
}

void QSSGRenderHelpers::rhiRenderRenderable(QSSGRhiContext &rhiCtx,
                                            const QSSGRhiGraphicsPipelineState &state,
                                            QSSGRenderableObject &object,
                                            bool *needsSetViewport)
{
    RenderHelpers::rhiRenderRenderable(&rhiCtx, state, object, needsSetViewport);
}

QSSGRenderHelpers::QSSGRenderHelpers()
{

}

void QSSGModelHelpers::ensureMeshes(const QSSGRenderContextInterface &contextInterface,
                                    QSSGRenderableNodes &renderableModels)
{
    QSSGLayerRenderData::prepareModelMeshesForRenderInternal(contextInterface, renderableModels, false);
}

bool QSSGModelHelpers::createRenderables(QSSGRenderContextInterface &contextInterface,
                                         const QSSGRenderableNodes &renderableModels,
                                         const QSSGRenderGraphObject &camera,
                                         RenderableFilter filter,
                                         float lodThreshold)
{
    QSSG_ASSERT(QSSGRenderGraphObject::isCamera(camera.type), return {});
    const auto &renderCamera = static_cast<const QSSGRenderCamera &>(camera);

    auto layer = QSSGLayerRenderData::getCurrent(*contextInterface.renderer());
    auto &flags = layer->layerPrepResult.flags; // TODO: Is there any point returing wasDirty here?
    const auto &cameraData = layer->getCameraRenderData(&renderCamera);
    return layer->prepareModelsForRender(renderableModels, flags, cameraData, filter, lodThreshold);
}

QMatrix4x4 QSSGCameraHelpers::getViewProjectionMatrix(const QSSGRenderGraphObject &camera)
{
    QSSG_ASSERT(QSSGRenderGraphObject::isCamera(camera.type), return {});

    const auto &renderCamera = static_cast<const QSSGRenderCamera &>(camera);
    QMatrix4x4 mat44{Qt::Uninitialized};
    renderCamera.calculateViewProjectionMatrix(mat44);
    return mat44;
}

void QSSGRenderExtensionHelpers::registerRenderResult(const QSSGRenderContextInterface &contextInterface,
                                                      QSSGExtensionId extension,
                                                      QRhiTexture *texture)
{
    if (auto *ext = QSSGRenderGraphObjectUtils::getExtension<QSSGRenderExtension>(extension))
        contextInterface.bufferManager()->registerExtensionResult(*ext, texture);
}

QT_END_NAMESPACE
