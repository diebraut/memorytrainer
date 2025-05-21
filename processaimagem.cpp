#include "processaimagem.h"

#include <QDebug>

processaImagem::processaImagem(QObject *parent)
{

}

QImage processaImagem::carregaImagem()
{
    QUrl caminhoImagem(p_caminhoImagem);
    QQmlEngine *engine = QQmlEngine::contextForObject(this)->engine();
    QQmlImageProviderBase *imageProviderBase = engine->imageProvider(caminhoImagem.host());
    QQuickImageProvider *imageProvider = static_cast<QQuickImageProvider*>(imageProviderBase);


    QSize imageSize;
    QString imageId = caminhoImagem.path().remove(0, 1);
    QImage imagem = imageProvider->requestImage(imageId, &imageSize, imageSize);

    if(imagem.isNull())
    {
        qDebug() << "Erro ao carregar a imagem";
        imagem = QImage();
    }
    else
    {
        if((p_anguloOrientacaoCamera == 90) || (p_anguloOrientacaoCamera == 270))
        {
             qDebug() << "rotate image um " + p_anguloOrientacaoCamera;
            int larguraImagem = p_tamanhoImagem.width();
            int alturaImagem = p_tamanhoImagem.height();

            p_tamanhoImagem.setWidth(alturaImagem);
            p_tamanhoImagem.setHeight(larguraImagem);

            int recorteX = p_rectRecorte.x();
            int recorteY = p_rectRecorte.y();
            int recorteLargura = p_rectRecorte.width();
            int recorteAltura = p_rectRecorte.height();

            p_rectRecorte.setRect(recorteY, recorteX, recorteAltura, recorteLargura);

            if(imagem.size().width() > imagem.size().height())
            {
                QTransform rotacao;
                rotacao.rotate(360 - p_anguloOrientacaoCamera);
                imagem = imagem.transformed(rotacao);

                qDebug() << "Rodou : " + (360 - p_anguloOrientacaoCamera);
            }
        }

        if(imagem.width() != p_tamanhoImagem.width())
        {
            imagem = imagem.scaled(p_tamanhoImagem);
        }

        imagem = imagem.copy(p_rectRecorte);
    }

    return imagem;
}

void processaImagem::removeImagemSalva()
{
    QFile::remove(p_caminhoSalvar);
}

QString processaImagem::caminhoImagem() const
{
    return p_caminhoImagem;
}

void processaImagem::setCaminhoImagem(const QString valor)
{
    if (valor != p_caminhoImagem)
    {
        p_caminhoImagem = valor;
        emit caminhoImagemChanged();
    }
}

QString processaImagem::caminhoSalvar() const
{
    return p_caminhoSalvar;
}

void processaImagem::setCaminhoSalvar(const QString valor)
{
    if (valor != p_caminhoSalvar)
    {
        p_caminhoSalvar = valor;
        emit caminhoSalvarChanged();
    }
}

QRect processaImagem::rectRecorte() const
{
    return p_rectRecorte;
}

void processaImagem::setRectRecorte(const QRect valor)
{
    bool alterou = false;

    if (valor.x() != p_rectRecorte.x())
    {
        p_rectRecorte.setX(valor.x());
        alterou = true;
    }

    if (valor.y() != p_rectRecorte.y())
    {
        p_rectRecorte.setY(valor.y());
        alterou = true;
    }

    if (valor.width() != p_rectRecorte.width())
    {
        p_rectRecorte.setWidth(valor.width());
        alterou = true;
    }

    if (valor.height() != p_rectRecorte.height())
    {
        p_rectRecorte.setHeight(valor.height());
        alterou = true;
    }

    if(alterou)
    {
        emit rectRecorteChanged();
    }
}

QSize processaImagem::tamanhoImagem() const
{
    return p_tamanhoImagem;
}

void processaImagem::setTamanhoImagem(const QSize valor)
{
    bool alterou = false;

    if (valor.width() != p_tamanhoImagem.width())
    {
        p_tamanhoImagem.setWidth(valor.width());
        alterou = true;
    }

    if (valor.height() != p_tamanhoImagem.height())
    {
        p_tamanhoImagem.setHeight(valor.height());
        alterou = true;
    }

    if(alterou)
    {
        emit tamanhoImagemChanged();
    }
}

int processaImagem::anguloOrientacaoCamera() const
{
    return p_anguloOrientacaoCamera;
}

void processaImagem::setAnguloOrientacaoCamera(const int valor)
{
    if (valor != p_anguloOrientacaoCamera)
    {
        p_anguloOrientacaoCamera = valor;
        emit anguloOrientacaoCameraChanged();
    }
}

int processaImagem::posicaoCamera() const
{
    return p_posicaoCamera;
}

void processaImagem::setPosicaoCamera(const int valor)
{
    if (valor != p_posicaoCamera)
    {
        p_posicaoCamera = valor;
        emit posicaoCameraChanged();
    }
}
