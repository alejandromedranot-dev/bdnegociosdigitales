# Documentación de Comandos de Contenedores Docker para SGBD

## Comando para contenedor de SQL Server sin Volumen

```
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=P@ssw0rd" \
   -p 1438:1433 --name servidorsqlserver \
   -d \
   mcr.microsoft.com/mssql/server:2019-latest
```

## Comando para contenedor de SQL Server con Volumen

```
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=P@ssw0rd" \
   -p 1438:1433 --name servidorsqlserver \
   -v v-mssqlevnd:/var/opt/mssql \
   -d  \
   mcr.microsoft.com/mssql/server:2019-latest
```






