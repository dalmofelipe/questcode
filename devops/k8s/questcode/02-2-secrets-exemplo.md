# SECRETS 

apiVersion: v1
kind: Secret
metadata:
  name: questcode
  namespace: staging
type: Opaque
data:
  MONGO_URI: <URI_DO_MONGO_DB_EM_BASE64>
  SECRET_OR_KEY: <SECRET_DO_APP_EM_BASE64>
  GITHUB_CLIENT_SECRET: <GITHUB_ACCOUNT_SECRET_EM_BASE64>
---
apiVersion: v1
kind: Secret
metadata:
  name: questcode
  namespace: prod
type: Opaque
data:
  MONGO_URI: <URI_DO_MONGO_DB_EM_BASE64>
  SECRET_OR_KEY: <SECRET_DO_APP_EM_BASE64>
  GITHUB_CLIENT_SECRET: <GITHUB_ACCOUNT_SECRET_EM_BASE64>


### BASE64 ENCODE

```bash

echo -n "apfjxkic-omyuobwd339805ak:60a06cd2ddfad610b9490d359d605407" | base64 -w 0

byBoZXhhIHNlcmEgbm9zc28=

```

### BASE64 DECODE

```bash

echo "byBoZXhhIHNlcmEgbm9zc28=" | base64 --decode

```

### MONGO_URI 

mongodb+srv://<username>:<password>@devops.etlqfoz.mongodb.net/<dbname>?retryWrites=true&w=majority
