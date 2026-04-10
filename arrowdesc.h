#ifndef ARROWDESC_H
#define ARROWDESC_H

#include <QObject>
#include <QSharedPointer>
#include <QVector>
#include <QString>

class ArrowDesc : public QObject {
    Q_OBJECT
    Q_PROPERTY(double x READ x WRITE setX NOTIFY xChanged)
    Q_PROPERTY(double y READ y WRITE setY NOTIFY yChanged)
    Q_PROPERTY(int rotationAngle READ rotationAngle WRITE setRotationAngle NOTIFY rotationAngleChanged)
    Q_PROPERTY(QString color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(double scaleFactor READ scaleFactor WRITE setScaleFactor NOTIFY scaleFactorChanged)

public:
    explicit ArrowDesc(QObject *parent = nullptr)
        : QObject(parent) {}

    ArrowDesc(double x,
              double y,
              int rotationAngle,
              const QString &color = QStringLiteral("red"),
              double scaleFactor = 1.0,
              QObject *parent = nullptr)
        : QObject(parent),
        m_x(x),
        m_y(y),
        m_rotationAngle(rotationAngle),
        m_color(color),
        m_scaleFactor(scaleFactor) {}

    double x() const { return m_x; }
    void setX(double value) {
        if (!qFuzzyCompare(m_x, value)) {
            m_x = value;
            emit xChanged();
        }
    }

    double y() const { return m_y; }
    void setY(double value) {
        if (!qFuzzyCompare(m_y, value)) {
            m_y = value;
            emit yChanged();
        }
    }

    int rotationAngle() const { return m_rotationAngle; }
    void setRotationAngle(int value) {
        if (m_rotationAngle != value) {
            m_rotationAngle = value;
            emit rotationAngleChanged();
        }
    }

    QString color() const { return m_color; }
    void setColor(const QString &value) {
        if (m_color != value) {
            m_color = value;
            emit colorChanged();
        }
    }

    double scaleFactor() const { return m_scaleFactor; }
    void setScaleFactor(double value) {
        if (!qFuzzyCompare(m_scaleFactor, value)) {
            m_scaleFactor = value;
            emit scaleFactorChanged();
        }
    }

signals:
    void xChanged();
    void yChanged();
    void rotationAngleChanged();
    void colorChanged();
    void scaleFactorChanged();

private:
    double m_x = 0.0;
    double m_y = 0.0;
    int m_rotationAngle = 0;
    QString m_color = QStringLiteral("red");
    double m_scaleFactor = 1.0;
};

using ArrowDescPtr = QSharedPointer<ArrowDesc>;
using ArrowDescList = QVector<ArrowDescPtr>;

#endif // ARROWDESC_H
