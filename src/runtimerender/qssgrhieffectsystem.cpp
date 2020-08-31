/****************************************************************************
**
** Copyright (C) 2008-2012 NVIDIA Corporation.
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

#include <QtQuick3DRuntimeRender/private/qssgrhieffectsystem_p.h>
#include <QtQuick3DRuntimeRender/private/qssgrenderer_p.h>
#include <QtQuick3DRuntimeRender/private/qssgrhiquadrenderer_p.h>

#include <QtCore/qloggingcategory.h>

QT_BEGIN_NAMESPACE

Q_DECLARE_LOGGING_CATEGORY(lcEffectSystem);
Q_LOGGING_CATEGORY(lcEffectSystem, "qt.quick3d.effects");

struct QSSGRhiEffectTexture
{
    QRhiTexture *texture;
    QRhiRenderPassDescriptor *renderPassDescriptor;
    QRhiTextureRenderTarget *renderTarget;
    QByteArray name;

    QSSGRhiSamplerDescription desc;
    QSSGAllocateBufferFlags flags;

    ~QSSGRhiEffectTexture()
    {
        delete texture;
        delete renderPassDescriptor;
        delete renderTarget;
    }
    QSSGRhiEffectTexture &operator=(const QSSGRhiEffectTexture &) = delete;
};

QSSGRhiEffectSystem::QSSGRhiEffectSystem(const QSSGRef<QSSGRenderContextInterface> &sgContext)
    : m_sgContext(sgContext.data())
{
}

QSSGRhiEffectSystem::~QSSGRhiEffectSystem()
{
    releaseResources();
}

void QSSGRhiEffectSystem::setup(QRhi *, QSize outputSize, QSSGRenderEffect *firstEffect)
{
    if (!firstEffect || outputSize.isEmpty()) {
        releaseResources();
        return;
    }
    m_outSize = outputSize;
    m_firstEffect = firstEffect;
}

QSSGRhiEffectTexture *QSSGRhiEffectSystem::findTexture(const QByteArray &bufferName)
{
    auto findTexture = [bufferName](const QSSGRhiEffectTexture *rt){ return rt->name == bufferName; };
    const auto foundIt = std::find_if(m_textures.cbegin(), m_textures.cend(), findTexture);
    QSSGRhiEffectTexture *result = foundIt == m_textures.cend() ? nullptr : *foundIt;
    return result;
}

QSSGRhiEffectTexture *QSSGRhiEffectSystem::getTexture(const QByteArray &bufferName, const QSize &size, QRhiTexture::Format format)
{
    QSSGRhiEffectTexture *result = findTexture(bufferName);

    // If not found, look for an unused texture
    if (!result) {
        //TODO: try to find a texture with the right size/format first
        auto findUnused = [](const QSSGRhiEffectTexture *rt){ return rt->name.isEmpty(); };
        const auto found = std::find_if(m_textures.cbegin(), m_textures.cend(), findUnused);
        if (found != m_textures.cend()) {
            result = *found;
            result->desc = {};
        }
    }

    if (!result) {
        result = new QSSGRhiEffectTexture {};
        m_textures.append(result);
    }

    QRhi *rhi = m_rhiContext->rhi();
    bool needsRebuild = result->texture && (result->texture->pixelSize() != size || result->texture->format() != format);

    if (!result->texture) {
        result->texture = rhi->newTexture(format, size, 1, QRhiTexture::RenderTarget);
        result->texture->create();
    } else if (needsRebuild) {
        result->texture->setPixelSize(size);
        result->texture->setFormat(format);
        result->texture->create();
    }

    if (!result->renderTarget) {
        result->renderTarget = rhi->newTextureRenderTarget({ result->texture });
        result->renderPassDescriptor = result->renderTarget->newCompatibleRenderPassDescriptor();
        result->renderTarget->setRenderPassDescriptor(result->renderPassDescriptor);
        result->renderTarget->create();
        m_pendingClears.insert(result->renderTarget);
    } else if (needsRebuild) {
        result->renderTarget->create();
        m_pendingClears.insert(result->renderTarget);
    }

    result->name = bufferName;
    return result;
}

void QSSGRhiEffectSystem::releaseTexture(QSSGRhiEffectTexture *texture)
{
    if (!texture->flags.isSceneLifetime())
        texture->name = {};
}

void QSSGRhiEffectSystem::releaseTextures()
{
    for (auto *t : qAsConst(m_textures))
        releaseTexture(t);
}

QRhiTexture *QSSGRhiEffectSystem::process(const QSSGRef<QSSGRhiContext> &rhiCtx,
                                          const QSSGRef<QSSGRenderer> &renderer,
                                          QRhiTexture *inTexture,
                                          QRhiTexture *inDepthTexture,
                                          QVector2D cameraClipRange)
{
    m_rhiContext = rhiCtx;
    m_renderer = renderer.data();
    if (!m_rhiContext || !m_renderer)
        return inTexture;
    m_depthTexture = inDepthTexture;
    m_cameraClipRange = cameraClipRange;
    Q_ASSERT(m_firstEffect);

    m_currentUbufIndex = 0;
    auto *currentEffect = m_firstEffect;
    QSSGRhiEffectTexture firstTex{ inTexture, nullptr, nullptr, {}, {}, {} };
    auto *latestOutput = doRenderEffect(currentEffect, &firstTex);
    firstTex.texture = nullptr; // make sure we don't delete inTexture when we go out of scope

    while ((currentEffect = currentEffect->m_nextEffect)) {
        auto *effectOut = doRenderEffect(currentEffect, latestOutput);
        releaseTexture(latestOutput);
        latestOutput = effectOut;
    }

    releaseTextures();
    return latestOutput->texture;
}

void QSSGRhiEffectSystem::releaseResources()
{
    for (auto *t : qAsConst(m_textures))
        m_rhiContext->invalidateCachedReferences(t->renderPassDescriptor);
    qDeleteAll(m_textures);
    m_textures.clear();
    m_currentOutput = nullptr;

    m_shaderPipelines.clear();
}

QSSGRhiEffectTexture *QSSGRhiEffectSystem::doRenderEffect(const QSSGRenderEffect *inEffect,
                                            QSSGRhiEffectTexture *inTexture)
{
    // Run through the effect commands and render the effect.
    const auto &theCommands = inEffect->commands;
    qCDebug(lcEffectSystem) << "START effect " << inEffect->className;
    QSSGRhiEffectTexture *finalOutputTexture = nullptr;
    QSSGRhiEffectTexture *currentOutput = nullptr;
    QSSGRhiEffectTexture *currentInput = inTexture;
    for (const auto &theCommand : theCommands) {
        qCDebug(lcEffectSystem).noquote() << "    >" << theCommand->typeAsString() << "--" << theCommand->debugString();

        switch (theCommand->m_type) {
        case CommandType::AllocateBuffer:
            allocateBufferCmd(static_cast<QSSGAllocateBuffer *>(theCommand), inTexture);
            break;

        case CommandType::ApplyBufferValue: {
            auto *applyCommand = static_cast<QSSGApplyBufferValue *>(theCommand);

            /*
                BufferInput { buffer: buf }
                  -> INPUT (qt_inputTexture) in the shader samples the texture for Buffer buf in the pass
                BufferInput { param: "ttt" }
                  -> ttt in the shader samples the input texture for the pass
                     (ttt also needs to be a TextureInput with a Texture{} to get the sampler declared in the shader code,
                      beware that without the BufferInput the behavior would change: ttt would then sample a dummy texture)
                BufferInput { buffer: buf; param: "ttt" }
                  -> ttt in the shader samples the texture for Buffer buf in the pass
            */

            auto *buffer = applyCommand->m_bufferName.isEmpty() ? inTexture : findTexture(applyCommand->m_bufferName);
            if (applyCommand->m_paramName.isEmpty())
                currentInput = buffer;
            else
                addTextureToShaderStages(applyCommand->m_paramName, buffer->texture, buffer->desc);
            break;
        }

        case CommandType::ApplyDepthValue: {
            // like BufferInput, but only the DepthInput { param: "ttt"} case matters
            auto *depthCommand = static_cast<QSSGApplyDepthValue *>(theCommand);
            static const QSSGRhiSamplerDescription depthDescription{ QRhiSampler::Nearest, QRhiSampler::Nearest,
                                                                     QRhiSampler::None,
                                                                     QRhiSampler::ClampToEdge, QRhiSampler::ClampToEdge };
            addTextureToShaderStages(depthCommand->m_paramName, m_depthTexture, depthDescription);
            break;
        }

        case CommandType::ApplyInstanceValue:
            applyInstanceValueCmd(static_cast<QSSGApplyInstanceValue *>(theCommand), inEffect);
            break;

        case CommandType::ApplyValue:
            applyValueCmd(static_cast<QSSGApplyValue *>(theCommand), inEffect);
            break;

        case CommandType::BindBuffer: {
            auto *bindCmd = static_cast<QSSGBindBuffer *>(theCommand);
            currentOutput = findTexture(bindCmd->m_bufferName);
            break;
        }

        case CommandType::BindShader:
            bindShaderCmd(static_cast<QSSGBindShader *>(theCommand));
            break;

        case CommandType::BindTarget: {
            auto targetCmd = static_cast<QSSGBindTarget*>(theCommand);
            // The command can define a format. If not, fall back to the effect's output format.
            // If the effect doesn't define an output format, use the same format as the input texture
            // ??? The direct GL path does not use the command's format: what's up with that?
            // (this is fairly pointless anyway, since it's always Unknown for the predefined effects)

            auto f = targetCmd->m_outputFormat == QSSGRenderTextureFormat::Unknown ?
                        inEffect->outputFormat : targetCmd->m_outputFormat.format;
            qCDebug(lcEffectSystem) << "      Target format" << toString(f);
            QRhiTexture::Format rhiFormat = f == QSSGRenderTextureFormat::Unknown ?
                        currentInput->texture->format() : QSSGBufferManager::toRhiFormat(f);
            // Make sure we use different names for each effect inside one frame
            QByteArray tmpName = QByteArrayLiteral("__output_").append(QByteArray::number(m_currentUbufIndex));
            currentOutput = getTexture(tmpName, m_outSize, rhiFormat);
            finalOutputTexture = currentOutput;
            break;
        }

        case CommandType::Render:
            renderCmd(currentInput, currentOutput);
            currentInput = inTexture; // default input for each new pass is defined to be original input
            break;

        default:
            qWarning() << "Effect command" << theCommand->typeAsString() << "not implemented";
            break;
        }
    }
    // TODO: release textures used by this effect now, instead of after processing all the effects
    qCDebug(lcEffectSystem) << "END effect " << inEffect->className;
    return finalOutputTexture;
}

void QSSGRhiEffectSystem::allocateBufferCmd(const QSSGAllocateBuffer *inCmd, QSSGRhiEffectTexture *inTexture)
{
    // Note: Allocate is used both to allocate new, and refer to buffer created earlier
    QSize bufferSize(m_outSize * qreal(inCmd->m_sizeMultiplier));

    QSSGRenderTextureFormat f = inCmd->m_format;
    QRhiTexture::Format rhiFormat = (f == QSSGRenderTextureFormat::Unknown) ? inTexture->texture->format()
                                                                            : QSSGBufferManager::toRhiFormat(f);

    QSSGRhiEffectTexture *buf = getTexture(inCmd->m_name, bufferSize, rhiFormat);
    auto filter = toRhi(inCmd->m_filterOp);
    auto tiling = toRhi(inCmd->m_texCoordOp);
    buf->desc = { filter, filter, QRhiSampler::None, tiling, tiling };
    buf->flags = inCmd->m_bufferFlags;
}

void QSSGRhiEffectSystem::applyInstanceValueCmd(const QSSGApplyInstanceValue *inCmd, const QSSGRenderEffect *inEffect)
{
    if (!m_currentShaderPipeline)
        return;

    const bool setAll = inCmd->m_propertyName.isEmpty();
    for (const QSSGRenderEffect::Property &property : qAsConst(inEffect->properties)) {
        if (setAll || property.name == inCmd->m_propertyName) {
            m_currentShaderPipeline->setUniformValue(property.name, property.value, property.shaderDataType);
            //qCDebug(lcEffectSystem) << "setUniformValue" << property.name << toString(property.shaderDataType) << "to" << property.value;
        }
    }
    for (const QSSGRenderEffect::TextureProperty &textureProperty : qAsConst(inEffect->textureProperties)) {
        if (setAll || textureProperty.name == inCmd->m_propertyName) {
            bool texAdded = false;
            QSSGRenderImage *image = textureProperty.texImage;
            if (image) {
                const auto &imageSource = image->m_imagePath;
                const QSSGRef<QSSGBufferManager> &theBufferManager(m_renderer->contextInterface()->bufferManager());
                if (!imageSource.isEmpty()) {
                    QSSGBufferManager::MipMode mipMode = QSSGBufferManager::MipModeNone;
                    // the mipFilterType here is only non-None when generateMipmaps was true on the Texture
                    if (textureProperty.mipFilterType != QSSGRenderTextureFilterOp::None)
                        mipMode = QSSGBufferManager::MipModeGenerated;
                    // ### would we want MipModeBsdf in some cases?

                    QSSGRenderImageTextureData theTextureData = theBufferManager->loadRenderImage(image, false, mipMode);

                    if (theTextureData.m_rhiTexture) {
                        const QSSGRhiSamplerDescription desc{
                            toRhi(textureProperty.minFilterType),
                            toRhi(textureProperty.magFilterType),
                            textureProperty.mipFilterType != QSSGRenderTextureFilterOp::None ? toRhi(textureProperty.mipFilterType) : QRhiSampler::None,
                            toRhi(textureProperty.clampType),
                            toRhi(textureProperty.clampType)
                        };
                        addTextureToShaderStages(textureProperty.name, theTextureData.m_rhiTexture, desc);
                        texAdded = true;
                    }
                    image->m_textureData = theTextureData;
                }
            }
            if (!texAdded) {
                // Something went wrong, e.g. image file not found. Still need to add a dummy texture for the shader
                qCDebug(lcEffectSystem) << "Using dummy texture for property" << textureProperty.name;
                addTextureToShaderStages(textureProperty.name, nullptr, {});
            }
        }
    }
}

void QSSGRhiEffectSystem::applyValueCmd(const QSSGApplyValue *inCmd, const QSSGRenderEffect *inEffect)
{
    if (!m_currentShaderPipeline)
        return;

    const auto &properties = inEffect->properties;
    const auto foundIt = std::find_if(properties.cbegin(), properties.cend(), [inCmd](const QSSGRenderEffect::Property &prop) {
        return (prop.name == inCmd->m_propertyName);
    });

    if (foundIt != properties.cend())
        m_currentShaderPipeline->setUniformValue(inCmd->m_propertyName, inCmd->m_value, foundIt->shaderDataType);
    else
        qWarning() << "Could not find effect property" << inCmd->m_propertyName;
}

static const char *effect_builtin_textureMapUV =
        "vec2 qt_effectTextureMapUV(vec2 uv)\n"
        "{\n"
        "    return uv;\n"
        "}\n";

static const char *effect_builtin_textureMapUVFlipped =
        "vec2 qt_effectTextureMapUV(vec2 uv)\n"
        "{\n"
        "    return vec2(uv.x, 1.0 - uv.y);\n"
        "}\n";

void QSSGRhiEffectSystem::bindShaderCmd(const QSSGBindShader *inCmd)
{
    m_currentTextures.clear();
    m_pendingClears.clear();

    // now we need a proper unique key (unique in the scene), the filenames are not sufficient
    const QByteArray key = inCmd->m_shaderPathKey
            + QByteArray::number(quintptr(inCmd->m_effect))
            + QByteArray::number(inCmd->m_passIndex);

    auto it = m_shaderPipelines.find(key);
    if (it != m_shaderPipelines.end()) {
        m_currentShaderPipeline = it.value().data();
        return;
    }

    qCDebug(lcEffectSystem) << "    generating new shader pipeline for lookup key" << key;

    const QSSGRef<QSSGProgramGenerator> &generator = m_renderer->contextInterface()->shaderProgramGenerator();
    generator->beginProgram();

    QSSGShaderLibraryManager *shaderLib = m_renderer->contextInterface()->shaderLibraryManager().data();
    {
        const QByteArray src = shaderLib->getShaderSource(inCmd->m_shaderPathKey, QSSGShaderCache::ShaderType::Vertex);
        QSSGStageGeneratorBase *vStage = generator->getStage(QSSGShaderGeneratorStage::Vertex);
        QRhi *rhi = m_renderer->contextInterface()->rhiContext()->rhi();
        if (rhi->isYUpInFramebuffer())
            vStage->append(effect_builtin_textureMapUV);
        else
            vStage->append(effect_builtin_textureMapUVFlipped);
        vStage->append(src);
    }
    {
        const QByteArray src = shaderLib->getShaderSource(inCmd->m_shaderPathKey, QSSGShaderCache::ShaderType::Fragment);
        QSSGStageGeneratorBase *fStage = generator->getStage(QSSGShaderGeneratorStage::Fragment);
        fStage->append(src);
    }

    const auto &shaderCache = m_renderer->contextInterface()->shaderCache();
    QSSGRef<QSSGRhiShaderStages> stages = generator->compileGeneratedRhiShader(key, ShaderFeatureSetList(), shaderLib, shaderCache);
    if (stages) {
        m_shaderPipelines.insert(key, QSSGRhiShaderStagesWithResources::fromShaderStages(stages));
        m_currentShaderPipeline = m_shaderPipelines[key].data();
    } else {
        m_currentShaderPipeline = nullptr;
    }
}

void QSSGRhiEffectSystem::renderCmd(QSSGRhiEffectTexture *inTexture, QSSGRhiEffectTexture *target)
{
    if (!m_currentShaderPipeline)
        return;

    if (!target) {
        qWarning("No effect render target?");
        return;
    }

    addTextureToShaderStages(QByteArrayLiteral("qt_inputTexture"), inTexture->texture, inTexture->desc);

    QRhiCommandBuffer *cb = m_rhiContext->commandBuffer();
    cb->debugMarkBegin(QByteArrayLiteral("Post-processing effect"));

    for (QRhiTextureRenderTarget *rt : m_pendingClears) {
        // Effects like motion blur use an accumulator texture that should
        // start out empty (and they are sampled in the first pass), so such
        // textures need an explicit clear. It is not applicable for the common
        // case of outputting into a texture because that will get a clear
        // anyway when rendering the quad.
        if (rt != target->renderTarget) {
            cb->beginPass(rt, Qt::transparent, { 1.0f, 0 });
            cb->endPass();
        }
    }
    m_pendingClears.clear();

    const QSize inputSize = inTexture->texture->pixelSize();
    const QSize outputSize = target->texture->pixelSize();
    addCommonEffectUniforms(inputSize, outputSize);

    // bake uniform buffer
    QRhiResourceUpdateBatch *rub = m_rhiContext->rhi()->nextResourceUpdateBatch();
    const void *cacheKey1 = reinterpret_cast<const void *>(this);
    const void *cacheKey2 = reinterpret_cast<const void *>(qintptr(m_currentUbufIndex));
    auto &ubs = m_rhiContext->uniformBufferSet({ cacheKey1, cacheKey2, nullptr, 0, QSSGRhiUniformBufferSetKey::Effects });
    m_currentShaderPipeline->bakeMainUniformBuffer(&ubs.ubuf, rub);
    m_renderer->rhiQuadRenderer()->prepareQuad(m_rhiContext.data(), rub);

    // do resource bindings
    const QRhiShaderResourceBinding::StageFlags VISIBILITY_ALL =
            QRhiShaderResourceBinding::VertexStage | QRhiShaderResourceBinding::FragmentStage;
    QSSGRhiContext::ShaderResourceBindingList bindings;
    for (const QSSGRhiTexture &rhiTex : m_currentTextures) {
        int binding = m_currentShaderPipeline->bindingForTexture(rhiTex.name);
        if (binding < 0) // may not be used in the shader (think qt_inputTexture, it's not given a shader samples INPUT)
            continue;
        qCDebug(lcEffectSystem) << "    -> texture binding" << binding << "for" << rhiTex.name;
        // Make sure to bind all samplers even if the texture is missing, otherwise we can get crash on some graphics APIs
        QRhiTexture *texture = rhiTex.texture ? rhiTex.texture : m_rhiContext->dummyTexture({}, rub);
        bindings.append(QRhiShaderResourceBinding::sampledTexture(binding,
                                                                  QRhiShaderResourceBinding::FragmentStage,
                                                                  texture,
                                                                  m_rhiContext->sampler(rhiTex.samplerDesc)));
    }
    bindings.append(QRhiShaderResourceBinding::uniformBuffer(0, VISIBILITY_ALL, ubs.ubuf));
    QRhiShaderResourceBindings *srb = m_rhiContext->srb(bindings);

    QSSGRhiGraphicsPipelineState ps;
    ps.viewport = QRhiViewport(0, 0, float(outputSize.width()), float(outputSize.height()));
    ps.shaderStages = m_currentShaderPipeline->stages();

    m_renderer->rhiQuadRenderer()->recordRenderQuadPass(m_rhiContext.data(), &ps, srb, target->renderTarget, QSSGRhiQuadRenderer::UvCoords);
    m_currentUbufIndex++;
    cb->debugMarkEnd();
}

void QSSGRhiEffectSystem::addCommonEffectUniforms(const QSize &inputSize, const QSize &outputSize)
{
    QRhi *rhi = m_rhiContext->rhi();

    QMatrix4x4 mvp;
    if (rhi->isYUpInFramebuffer() != rhi->isYUpInNDC())
        mvp.data()[5] = -1.0f;
    m_currentShaderPipeline->setUniformValue(QByteArrayLiteral("qt_modelViewProjection"), mvp, QSSGRenderShaderDataType::Matrix4x4);

    QVector2D size(inputSize.width(), inputSize.height());
    m_currentShaderPipeline->setUniformValue(QByteArrayLiteral("qt_inputSize"), size, QSSGRenderShaderDataType::Vec2);

    size = QVector2D(outputSize.width(), outputSize.height());
    m_currentShaderPipeline->setUniformValue(QByteArrayLiteral("qt_outputSize"), size, QSSGRenderShaderDataType::Vec2);

    float fc = float(m_sgContext->frameCount());
    m_currentShaderPipeline->setUniformValue(QByteArrayLiteral("qt_frame_num"), fc, QSSGRenderShaderDataType::Float);

    float fps = float(m_sgContext->getFPS().first);
    m_currentShaderPipeline->setUniformValue(QByteArrayLiteral("qt_fps"), fps, QSSGRenderShaderDataType::Float);

    // Bames and values for uniforms that are also used by default and/or
    // custom materials must always match, effects must not deviate.

    m_currentShaderPipeline->setUniformValue(QByteArrayLiteral("qt_cameraProperties"), m_cameraClipRange, QSSGRenderShaderDataType::Vec2);

    float vp = rhi->isYUpInFramebuffer() ? 1.0f : -1.0f;
    m_currentShaderPipeline->setUniformValue(QByteArrayLiteral("qt_normalAdjustViewportFactor"), vp, QSSGRenderShaderDataType::Float);

    const float nearClip = rhi->isClipDepthZeroToOne() ? 0.0f : -1.0f;
    m_currentShaderPipeline->setUniformValue(QByteArrayLiteral("qt_nearClipValue"), nearClip, QSSGRenderShaderDataType::Float);
}

void QSSGRhiEffectSystem::addTextureToShaderStages(const QByteArray &name,
                                                   QRhiTexture *texture,
                                                   const QSSGRhiSamplerDescription &samplerDescription)
{
    if (!m_currentShaderPipeline)
        return;

    static const QSSGRhiSamplerDescription defaultDescription { QRhiSampler::Linear, QRhiSampler::Linear, QRhiSampler::None,
                                                                QRhiSampler::ClampToEdge, QRhiSampler::ClampToEdge };
    bool validDescription = samplerDescription.magFilter != QRhiSampler::None;

    // This is a map for a reason: there can be multiple calls to this function
    // for the same 'name', with a different 'texture', take the last value
    // into account only.
    m_currentTextures.insert(name, { name, texture, validDescription ? samplerDescription : defaultDescription});
}

QT_END_NAMESPACE
