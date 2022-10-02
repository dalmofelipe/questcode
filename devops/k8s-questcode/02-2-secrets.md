
# Secrets

Atlas MongoDB
https://www.mongodb.com/atlas/database

API do Github
https://docs.github.com/pt/rest/guides/getting-started-with-the-rest-api


### Atlas MongoDB String Conn

- mongodb+srv://<username>:<password>@<cluster-name>/<dbname>


# Codificando chaves em base64

```bash
echo -n <algum-texto> | base64 -w 0
```


# DEcodificando base64

```bash
echo -n <texto-encodado> | base64 -d
echo -n <texto-encodado> | base64 -d -i
echo -n <texto-encodado> | base64 --decode
```


# k8s Secrets

```yaml

apiVersion: v1
kind: Secret
metadata:
  name: questcode
  namespace: staging
type: Opaque
data:
  MONGO_URI: URI_DO_MONGO_DB_EM_BASE64
  SECRET_OR_KEY: SECRET_DO_APP_EM_BASE64
  GITHUB_CLIENT_SECRET: GITHUB_ACCOUNT_SECRET_EM_BASE64
---
apiVersion: v1
kind: Secret
metadata:
  name: questcode
  namespace: prod
type: Opaque
data:
  MONGO_URI: URI_DO_MONGO_DB_EM_BASE64
  SECRET_OR_KEY: SECRET_DO_APP_EM_BASE64
  GITHUB_CLIENT_SECRET: GITHUB_ACCOUNT_SECRET_EM_BASE64

```


