#ifndef NETWORKCHECKER_H
#define NETWORKCHECKER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>

class NetworkChecker : public QObject
{
    Q_OBJECT
public:
    explicit NetworkChecker(QObject *parent = nullptr);

    Q_INVOKABLE void checkInternetConnection();

signals:
    void networkStatusChanged(bool isOnline);

private slots:
    void onNetworkReply(QNetworkReply *reply);

private:
    QNetworkAccessManager m_networkManager;
};

#endif // NETWORKCHECKER_H
