# San Patrignano Website

Questo è un progetto per realizzare un sito web fake della comunità di San Patrignano a scopo di demo per il nuovo chatbot che si sta realizzando in collaborazione con la comunità di San Patrignano.

Per avere il sito web funzionante sulla vostra macchine è necessario scaricare e installare sia [Virtual Box](https://www.virtualbox.org/) che [Vagrant](https://www.vagrantup.com/).

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
user: user
password: password
```

