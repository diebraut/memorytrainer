#include "networkchecker.h"

#include <QJsonDocument>
#include <QJsonObject>

NetworkChecker::NetworkChecker(QObject *parent) : QObject(parent)
{
    // Connect the finished signal to check the reply
    connect(&m_networkManager, &QNetworkAccessManager::finished, this, &NetworkChecker::onNetworkReply);
}

void NetworkChecker::checkInternetConnection()
{
    // Perform a simple network request to a reliable URL
    QNetworkRequest request(QUrl("https://www.google.com"));
    QNetworkReply *reply = m_networkManager.get(request);
    reply->setProperty("requestType", "internet");
}

void NetworkChecker::checkWikipediaSummary(const QString &pageUrl)
{
    QUrl summaryUrl;
    if (!buildWikipediaSummaryUrl(pageUrl, summaryUrl)) {
        emit wikipediaSummaryChecked(pageUrl, false, QString(), QString());
        return;
    }

    QNetworkRequest request(QUrl("https://www.wikipedia.org"));
    request.setHeader(QNetworkRequest::UserAgentHeader, "MemoryTrainer/1.0");

    QNetworkReply *reply = m_networkManager.get(request);
    reply->setProperty("requestType", "summaryInternetCheck");
    reply->setProperty("pageUrl", pageUrl);
    reply->setProperty("summaryUrl", summaryUrl);
}

bool NetworkChecker::buildWikipediaSummaryUrl(const QString &pageUrl, QUrl &summaryUrl) const
{
    QUrl url(pageUrl.trimmed());
    if (!url.isValid() || url.host().isEmpty())
        return false;

    QString host = url.host().toLower();
    if (!host.endsWith(".wikipedia.org") && host != "wikipedia.org")
        return false;

    host.replace(".m.wikipedia.org", ".wikipedia.org");

    const QString path = url.path();
    if (!path.startsWith("/wiki/"))
        return false;

    const QString title = QUrl::fromPercentEncoding(path.mid(QStringLiteral("/wiki/").size()).toUtf8());
    if (title.trimmed().isEmpty())
        return false;

    const QString encodedTitle = QString::fromUtf8(QUrl::toPercentEncoding(title, QByteArray(), "/?#"));
    summaryUrl = QUrl(QStringLiteral("https://") + host + QStringLiteral("/api/rest_v1/page/summary/") + encodedTitle);
    return summaryUrl.isValid();
}

void NetworkChecker::onNetworkReply(QNetworkReply *reply)
{
    const QString requestType = reply->property("requestType").toString();

    if (requestType == "summaryInternetCheck") {
        const QString pageUrl = reply->property("pageUrl").toString();
        const QUrl summaryUrl = reply->property("summaryUrl").toUrl();
        const bool isOnline = (reply->error() == QNetworkReply::NoError);

        if (!isOnline) {
            emit wikipediaSummaryChecked(pageUrl, false, QString(), QString());
        } else {
            QNetworkRequest request(summaryUrl);
            request.setHeader(QNetworkRequest::UserAgentHeader, "MemoryTrainer/1.0");

            QNetworkReply *summaryReply = m_networkManager.get(request);
            summaryReply->setProperty("requestType", "wikipediaSummary");
            summaryReply->setProperty("pageUrl", pageUrl);
        }

        reply->deleteLater();
        return;
    }

    if (requestType == "wikipediaSummary") {
        const QString pageUrl = reply->property("pageUrl").toString();
        const int httpStatus = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        bool summaryAvailable = reply->error() == QNetworkReply::NoError && httpStatus >= 200 && httpStatus < 300;
        QString title;
        QString extract;

        if (summaryAvailable) {
            const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
            const QJsonObject obj = doc.object();
            title = obj.value("title").toString().trimmed();
            extract = obj.value("extract").toString().trimmed();
            summaryAvailable = !extract.isEmpty();
        }

        emit wikipediaSummaryChecked(pageUrl, summaryAvailable, title, extract);
        reply->deleteLater();
        return;
    }

    // Check if the request was successful
    const bool isOnline = (reply->error() == QNetworkReply::NoError);
    emit networkStatusChanged(isOnline);
    reply->deleteLater();
}
