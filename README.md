# Config file (config.yml)
```
staging:
  host: 'pepe'
  port: 'porte'
  user: 'usi'
  database: 'usi'
  password: 'passi'
production:
  host: 'pepe'
  port: 'porte'
  user: 'usi'
  database: 'usi'
  password: 'passi'
  ```


# Cargar datos para compañía en desarrollo local

1. Crear la compañía y su infraestructura
Ejecutar el script de api
```
rake company_setup:go\[company_id,company_name,company_slug\]
```
Importante que el slug de la compañía sea único entre todos los desarrolladores y que empiece por 'demo'

Como en una compañía normal, realizar todos los pasos de creación de bucket en storage, dataset en bigquery y conexión con bigquery (localizado todo en europa/europa oeste 1)


2. Ejecutar la generación de csv
```
ruby app.rb
```
Al rellenar los inputs pedidos generará una serie de ficheros .csv con los datos


3. Cargar datos en base de datos local

Generar el fichero config.yml
```
development:
  host: 'localhost'
  port: 5432
  database: 'loyal_guru'
  user: 'my_user'
  password: ''
```

Ejecutar
```
ruby import.rb
```

Si lanza un error 'psql commando not found' se puede solventar modificando la llamada a psql en el script
```
system("PGPASSWORD=#{CONFIG["password"]} /path/to/exec/psql -h #{CONFIG["host"]} -U #{CONFIG["user"]} #{CONFIG["database"]} -p #{CONFIG["port"]} -c \"\\copy #{slug}.#{table}(#{headers}) FROM '#{PATH_FILES}/#{file}' DELIMITER ',' CSV HEADER\"")
```

o bien añadiendo psql al PATH

En este punto ya están los datos cargados en la base de datos local y únicamente hay que ejecutar los pumps.
