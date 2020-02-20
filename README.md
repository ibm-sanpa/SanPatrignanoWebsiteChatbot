# San Patrignano Demo Website

Questo è un progetto per realizzare un sito web demo della comunità di San Patrignano per il nuovo chatbot che si sta realizzando in collaborazione con la comunità di San Patrignano. Il sito web è realizzato con Wordpress (come il sito web originale) e contiene solo alcuni elementi della Home page con il chatbot.

## San Patrignano Demo Website

At the [following URL](https://sanpatrignano.softlayer.com/) you can find the San Patrignano Demo Website. This URL i NOT REGISTERED in a public DNS, for this reason, you need to add the following line to your ```/etc/hosts```file.

```
169.60.176.146  sanpatrignano.softlayer.com
```
 
## San Patrignano Demo Website in Local

Per avere il sito web funzionante sulla vostra macchina di sviluppo è necessario scaricare e installare sia [Virtual Box](https://www.virtualbox.org/) che [Vagrant](https://www.vagrantup.com/).

Una volta installati questi prerequisiti sarà sufficiente eseguire i seguenti passi:

```
1. cd  <work_dir>
2. git clone https://github.com/ibm-sanpa/SanPatrignanoWebsiteChatbot
3. cd SanPatrignanoWebsiteChatbot
4. vagrant up
5. sudo vi /etc/hosts
6. Aggiungere questa riga al file:
   192.168.100.2   www.sanpa.org
```

Per vedere il sito web funzionante aprire il browser e accedere all'indirizzo:

```
www.sanpa.org
```

Per accedere al pannello di amministrazione accedere all'URL:

```
www.sanpa.org/wp-admin
```

e inserire le credenziali

```
Nome utente o indirizzo email: user
Password: password
```

