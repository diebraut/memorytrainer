#ifndef EXCLUDEAEREA_H
#define EXCLUDEAEREA_H

#include <QRect>
#include <QObject>
#include <QSharedPointer>
#include <QVector>

// Definition der ExcludeAerea-Klasse
class ExcludeAerea : public QObject {
    Q_OBJECT
    Q_PROPERTY(QRect rect READ rect WRITE setRect NOTIFY rectChanged)
    Q_PROPERTY(int rotationAngle READ rotationAngle WRITE setRotationAngle NOTIFY rotationAngleChanged)

public:
    // Konstruktoren
    ExcludeAerea(QObject *parent = nullptr) : QObject(parent), m_rotationAngle(0) {}

    ExcludeAerea(const QRect &rect, int rotationAngle, QObject *parent = nullptr)
        : QObject(parent), m_rect(rect), m_rotationAngle(rotationAngle) {}

    QRect rect() const { return m_rect; }
    void setRect(const QRect &rect) {
        if (m_rect != rect) {
            m_rect = rect;
            emit rectChanged();
        }
    }

    int rotationAngle() const { return m_rotationAngle; }
    void setRotationAngle(int angle) {
        if (m_rotationAngle != angle) {
            m_rotationAngle = angle;
            emit rotationAngleChanged();
        }
    }

signals:
    void rectChanged();
    void rotationAngleChanged();

private:
    QRect m_rect;
    int m_rotationAngle;
};

// Typdefinitionen für Shared Pointer und Listen von ExcludeAerea
typedef QSharedPointer<ExcludeAerea> ExcludeAereaPtr;
typedef QVector<ExcludeAereaPtr> ExcludeAereaList;

#endif // EXCLUDEAEREA_H
