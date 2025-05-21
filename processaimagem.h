#ifndef PROCESSAIMAGEM_H
#define PROCESSAIMAGEM_H

#include <QObject>
#include <QImage>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickImageProvider>
#include <QFile>

#include "provedorimagem.h"

class processaImagem : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString caminhoImagem READ caminhoImagem WRITE setCaminhoImagem NOTIFY caminhoImagemChanged)
    Q_PROPERTY(QString caminhoSalvar READ caminhoSalvar WRITE setCaminhoSalvar NOTIFY caminhoSalvarChanged)
    Q_PROPERTY(QRect rectRecorte READ rectRecorte WRITE setRectRecorte NOTIFY rectRecorteChanged)
    Q_PROPERTY(QSize tamanhoImagem READ tamanhoImagem WRITE setTamanhoImagem NOTIFY tamanhoImagemChanged)
    Q_PROPERTY(int anguloOrientacaoCamera READ anguloOrientacaoCamera WRITE setAnguloOrientacaoCamera NOTIFY anguloOrientacaoCameraChanged)
    Q_PROPERTY(int posicaoCamera READ posicaoCamera WRITE setPosicaoCamera NOTIFY posicaoCameraChanged)

public slots:
    QImage carregaImagem();
    void removeImagemSalva();

public:
    processaImagem(QObject *parent = 0);

    QString caminhoImagem() const;
    void setCaminhoImagem(const QString valor);

    QString caminhoSalvar() const;
    void setCaminhoSalvar(const QString valor);

    QRect rectRecorte() const;
    void setRectRecorte(const QRect valor);

    QSize tamanhoImagem() const;
    void setTamanhoImagem(const QSize valor);

    int anguloOrientacaoCamera() const;
    void setAnguloOrientacaoCamera(const int valor);

    int posicaoCamera() const;
    void setPosicaoCamera(const int valor);

private:
    QString p_caminhoImagem = "";
    QString p_caminhoSalvar = "";
    QRect p_rectRecorte = QRect(0, 0, 0, 0);
    QSize p_tamanhoImagem = QSize(0, 0);
    int p_anguloOrientacaoCamera = 0;
    int p_posicaoCamera = 0;

signals:
    void caminhoImagemChanged();
    void caminhoSalvarChanged();
    void rectRecorteChanged();
    void tamanhoImagemChanged();
    void anguloOrientacaoCameraChanged();
    void posicaoCameraChanged();
};

#endif // PROCESSAIMAGEM_H
