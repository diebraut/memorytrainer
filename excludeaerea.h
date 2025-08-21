#ifndef EXCLUDEAEREA_H
#define EXCLUDEAEREA_H

#include <QObject>
#include <QRect>
#include <QSharedPointer>
#include <QVector>
#include <QString>

class ExcludeAerea : public QObject {
    Q_OBJECT
    Q_PROPERTY(QRect rect READ rect WRITE setRect NOTIFY rectChanged)
    Q_PROPERTY(int rotationAngle READ rotationAngle WRITE setRotationAngle NOTIFY rotationAngleChanged)
    Q_PROPERTY(QString color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(bool isBackgroundRectancle READ isBackgroundRectancle WRITE setIsBackgroundRectancle NOTIFY isBackgroundRectancleChanged)

public:
    explicit ExcludeAerea(QObject *parent = nullptr)
        : QObject(parent) {}

    ExcludeAerea(const QRect &rect,
                 int rotationAngle,
                 const QString &color = QStringLiteral("black"),
                 bool isBackgroundRectancle = false,
                 QObject *parent = nullptr)
        : QObject(parent),
        m_rect(rect),
        m_rotationAngle(rotationAngle),
        m_color(color),
        m_isBackgroundRectancle(isBackgroundRectancle) {}

    // rect
    QRect rect() const { return m_rect; }
    void setRect(const QRect &rect) {
        if (m_rect != rect) { m_rect = rect; emit rectChanged(); }
    }

    // rotation
    int rotationAngle() const { return m_rotationAngle; }
    void setRotationAngle(int angle) {
        if (m_rotationAngle != angle) { m_rotationAngle = angle; emit rotationAngleChanged(); }
    }

    // color
    QString color() const { return m_color; }
    void setColor(const QString &color) {
        if (m_color != color) { m_color = color; emit colorChanged(); }
    }

    // background flag
    bool isBackgroundRectancle() const { return m_isBackgroundRectancle; }
    void setIsBackgroundRectancle(bool isBackgroundRectancle) {
        if (m_isBackgroundRectancle != isBackgroundRectancle) {
            m_isBackgroundRectancle = isBackgroundRectancle;
            emit isBackgroundRectancleChanged();
        }
    }

signals:
    void rectChanged();
    void rotationAngleChanged();
    void colorChanged();
    void isBackgroundRectancleChanged();

private:
    QRect m_rect;
    int m_rotationAngle = 0;
    QString m_color = QStringLiteral("black");
    bool m_isBackgroundRectancle = false;
};

using ExcludeAereaPtr = QSharedPointer<ExcludeAerea>;
using ExcludeAereaList = QVector<ExcludeAereaPtr>;

#endif // EXCLUDEAEREA_H
