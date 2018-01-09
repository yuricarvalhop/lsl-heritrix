### Iniciando o MongoDB ###

* Se for iniciado usando "service start mongod" e "mongo", você provavelmente vai receber alguns WARNINGS sobre numactl e algumas flags
* Para corrigir esses WARNINGS, inicie da seguinte forma:
* Execução:
*   service mongod stop
*   echo "never" > /sys/kernel/mm/transparent_hugepage/
*   echo "never" > /sys/kernel/mm/transparent_hugepage/defrag
*   numactl --interleave=all mongod --quiet --config /etc/mongodb.conf
   
### Iniciando os scripts dos crawlers de 7.5k e 50k ###

* Caminho: cd /var/diogomarques/webpage-change-detection/
* Execução: 
*   ./crawler.rb [CRAWL_DIR], [ENVIRONMENT], [START_TIME], [MIGRATE] 
*   CRAWL_DIR   = 'crawl_7500' or 'crawl_50000'
*   ENVIRONMENT = 'migration'  or 'new_crawl'
*   START_TIME  = Date on format yyyy-mm-dd
*   MIGRATE     = Migrate crawl files to DB: 0 or 1
* Mais infos sobre ENVIRONMENT no arquivo util/mongoid.yml
* Exemplos:
*   ./crawler.rb crawl_7500 migration 2016-08-31 1
*   ./crawler.rb crawl_50000 new_crawl 2016-08-31 0

### Iniciando o heritrix crawler ###

* Caminho: cd /var/heritrix-3.2.0/scripts/
* Execução: 
*     ./crawl_heritrix.rb [START_TIME]
*     START_TIME = Date on format yyyy-mm-dd
