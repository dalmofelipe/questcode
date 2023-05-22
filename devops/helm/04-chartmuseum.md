# CHARTMUSEUM

### LISTANDO CHARTS

curl http://localhost:30010/api/charts


### EXCLUINDO CHARTS HOSPEDADOS NO CLUSTER

```bash
curl --request DELETE https://<msrhost>/charts/api/<namespace>/<reponame>/charts/<chartname>/<chartversion> -u <username>:<password> --cacert ca.crt

curl --request DELETE https://localhost:30010/charts/api/<namespace>/<reponame>/charts/<chartname>/<chartversion>

# excluir charts do cluster
curl -X DELETE localhost:8080/api/charts/mychart/0.1.1
# response
{"deleted":true}

# ex
curl -X DELETE http://localhost:30010/api/charts/frontend/0.1.0
curl -X DELETE http://localhost:30010/api/charts/backend-scm/0.1.0
curl -X DELETE http://localhost:30010/api/charts/backend-user/0.1.0
```
