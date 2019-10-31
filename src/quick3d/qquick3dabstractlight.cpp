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

#include "qquick3dabstractlight_p.h"
#include "qquick3dobject_p_p.h"

#include <QtQuick3DRuntimeRender/private/qssgrenderlight_p.h>

QT_BEGIN_NAMESPACE

/*!
    \qmltype Light
    \inherits Node
    \instantiates QQuick3DAbstractLight
    \inqmlmodule QtQuick3D
    \brief An uncreatable abstract base type for all lights.

    Light itself is an uncreatable base for all of its subtypes. The subtypes provide multiple
    options to determine the style of the light.

    \sa AreaLight, DirectionalLight, PointLight
*/

/*!
 * \qmlproperty color Light::color
 * This property defines the color applied to models illuminated by this light.
 *
 */

/*!
 * \qmlproperty color Light::ambientColor
 *
 * The property defines the ambient color applied to materials before being lit by this light.
 *
 */

/*!
 * \qmlproperty real Light::brightness
 *
 * This property defines an overall multiplier for this light’s effects.
 *
 */

/*!
 * \qmlproperty Node Light::scope
 *
 * The property allows the selection of a Node in the scene. Only that node and it's children
 * are affected by this light.
 *
 */

/*!
 * \qmlproperty bool Light::castsShadow
 *
 * When this property is enabled, the light will cast shadows.
 *
 */

/*!
 * \qmlproperty real Light::shadowBias
 *
 * This property is used to tweak the shadowing effect when when objects
 * are casting shadows on themselves. The value range is [-1.0, 1.0]. Generally value
 * inside [-0.1, 0.1] is sufficient.
 *
 */

/*!
 * \qmlproperty real Light::shadowFactor
 *
 * This property determines how dark the cast shadows should be. The value range is [0, 100], where
 * 0 mean no shadows and 100 means the light is fully shadowed.
 *
 */

/*!
 * \qmlproperty enumeration Light::shadowMapQuality
 *
 * The property sets the quality of the shadow map created for shadow rendering. Lower quality uses
 * less resources, but produces lower quality shadows while higher quality uses more resources, but
 * produces better quality shadows.
 *
 * Supported quality values are:
 * \list
 * \li Light.ShadowMapQualityLow    - Render shadowmap using 256x256 texture
 * \li Light.ShadowMapQualityMedium - Render shadowmap using 512x512 texture
 * \li Light.ShadowMapQualityHigh   - Render shadowmap using 1024x1024 texture
 * \li Light.ShadowMapQualityVeryHigh - Render shadowmap using 2048x2048 texture
 * \endlist
 *
 * The default value is Light.ShadowMapQualityLow
 *
 */

/*!
 * \qmlproperty real Light::shadowMapFar
 *
 * The property determines the maximum distance for the shadow map. Smaller
 * values improve the precision and effects of the map.
 *
 */

/*!
 * \qmlproperty real Light::shadowFilter
 *
 * This property sets how much blur is applied to the shadows.
 *
 */

QQuick3DObject::Type QQuick3DAbstractLight::type() const
{
    return QQuick3DObject::Light;
}

QColor QQuick3DAbstractLight::color() const
{
    return m_color;
}

QColor QQuick3DAbstractLight::ambientColor() const
{
    return m_ambientColor;
}

float QQuick3DAbstractLight::brightness() const
{
    return m_brightness;
}

QQuick3DNode *QQuick3DAbstractLight::scope() const
{
    return m_scope;
}

bool QQuick3DAbstractLight::castsShadow() const
{
    return m_castsShadow;
}

float QQuick3DAbstractLight::shadowBias() const
{
    return m_shadowBias;
}

float QQuick3DAbstractLight::shadowFactor() const
{
    return m_shadowFactor;
}

QQuick3DAbstractLight::QSSGShadowMapQuality QQuick3DAbstractLight::shadowMapQuality() const
{
    return m_shadowMapQuality;
}

float QQuick3DAbstractLight::shadowMapFar() const
{
    return m_shadowMapFar;
}

float QQuick3DAbstractLight::shadowFilter() const
{
    return m_shadowFilter;
}

void QQuick3DAbstractLight::setColor(const QColor &color)
{
    if (m_color == color)
        return;

    m_color = color;
    m_dirtyFlags.setFlag(DirtyFlag::ColorDirty);
    emit colorChanged(m_color);
    update();
}

void QQuick3DAbstractLight::setAmbientColor(const QColor &ambientColor)
{
    if (m_ambientColor == ambientColor)
        return;

    m_ambientColor = ambientColor;
    m_dirtyFlags.setFlag(DirtyFlag::ColorDirty);
    emit ambientColorChanged(m_ambientColor);
    update();
}

void QQuick3DAbstractLight::setBrightness(float brightness)
{
    if (qFuzzyCompare(m_brightness, brightness))
        return;

    m_brightness = brightness;
    m_dirtyFlags.setFlag(DirtyFlag::BrightnessDirty);
    emit brightnessChanged(m_brightness);
    update();
}

void QQuick3DAbstractLight::setScope(QQuick3DNode *scope)
{
    if (m_scope == scope)
        return;

    m_scope = scope;
    emit scopeChanged(m_scope);
    update();
}

void QQuick3DAbstractLight::setCastsShadow(bool castsShadow)
{
    if (m_castsShadow == castsShadow)
        return;

    m_castsShadow = castsShadow;
    m_dirtyFlags.setFlag(DirtyFlag::ShadowDirty);
    emit castsShadowChanged(m_castsShadow);
}

void QQuick3DAbstractLight::setShadowBias(float shadowBias)
{
    if (qFuzzyCompare(m_shadowBias, shadowBias))
        return;

    m_shadowBias = shadowBias;
    m_dirtyFlags.setFlag(DirtyFlag::ShadowDirty);
    emit shadowBiasChanged(m_shadowBias);
}

void QQuick3DAbstractLight::setShadowFactor(float shadowFactor)
{
    if (qFuzzyCompare(m_shadowFactor, shadowFactor))
        return;

    m_shadowFactor = shadowFactor;
    m_dirtyFlags.setFlag(DirtyFlag::ShadowDirty);
    emit shadowFactorChanged(m_shadowFactor);
}

void QQuick3DAbstractLight::setShadowMapQuality(
        QQuick3DAbstractLight::QSSGShadowMapQuality shadowMapQuality)
{
    if (m_shadowMapQuality == shadowMapQuality)
        return;

    m_shadowMapQuality = shadowMapQuality;
    m_dirtyFlags.setFlag(DirtyFlag::ShadowDirty);
    emit shadowMapQualityChanged(m_shadowMapQuality);
}

void QQuick3DAbstractLight::setShadowMapFar(float shadowMapFar)
{
    if (qFuzzyCompare(m_shadowMapFar, shadowMapFar))
        return;

    m_shadowMapFar = shadowMapFar;
    m_dirtyFlags.setFlag(DirtyFlag::ShadowDirty);
    emit shadowMapFarChanged(m_shadowMapFar);
}

void QQuick3DAbstractLight::setShadowFilter(float shadowFilter)
{
    if (qFuzzyCompare(m_shadowFilter, shadowFilter))
        return;

    m_shadowFilter = shadowFilter;
    m_dirtyFlags.setFlag(DirtyFlag::ShadowDirty);
    emit shadowFilterChanged(m_shadowFilter);
}

quint32 QQuick3DAbstractLight::mapToShadowResolution(QSSGShadowMapQuality quality)
{
    switch (quality) {
    case QSSGShadowMapQuality::ShadowMapQualityMedium:
        return 9;
    case QSSGShadowMapQuality::ShadowMapQualityHigh:
        return 10;
    case QSSGShadowMapQuality::ShadowMapQualityVeryHigh:
        return 11;
    default:
        break;
    }
    return 8;
}

QSSGRenderGraphObject *QQuick3DAbstractLight::updateSpatialNode(QSSGRenderGraphObject *node)
{
    Q_ASSERT_X(node, __FUNCTION__, "Node must have been created in parent class.");

    QQuick3DNode::updateSpatialNode(node);

    QSSGRenderLight *light = static_cast<QSSGRenderLight *>(node);

    if (m_dirtyFlags.testFlag(DirtyFlag::ColorDirty)) {
        m_dirtyFlags.setFlag(DirtyFlag::ColorDirty, false);
        light->m_diffuseColor = QVector3D(m_color.redF(), m_color.greenF(), m_color.blueF());
        light->m_specularColor = light->m_diffuseColor;
        light->m_ambientColor
                = QVector3D(m_ambientColor.redF(), m_ambientColor.greenF(), m_ambientColor.blueF());
    }

    if (m_dirtyFlags.testFlag(DirtyFlag::BrightnessDirty)) {
        m_dirtyFlags.setFlag(DirtyFlag::BrightnessDirty, false);
        light->m_brightness = m_brightness;
    }

    if (m_dirtyFlags.testFlag(DirtyFlag::ShadowDirty)) {
        m_dirtyFlags.setFlag(DirtyFlag::ShadowDirty, false);
        light->m_castShadow = m_castsShadow;
        light->m_shadowBias = m_shadowBias;
        light->m_shadowFactor = m_shadowFactor;
        light->m_shadowMapRes = mapToShadowResolution(m_shadowMapQuality);
        light->m_shadowMapFar = m_shadowMapFar;
        light->m_shadowFilter = m_shadowFilter;
    }

    if (m_scope) {
        light->m_scope
                = static_cast<QSSGRenderNode*>(QQuick3DObjectPrivate::get(m_scope)->spatialNode);
    } else {
        light->m_scope = nullptr;
    }

    return node;
}

QT_END_NAMESPACE
