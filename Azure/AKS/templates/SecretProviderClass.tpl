apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: ${nginx_ingress_secret_class}
  namespace: ${nginx_ingress_namespace}
spec:
  provider: azure
  secretObjects:
  - secretName: ${nginx_ingress_secret_name}
    type: kubernetes.io/tls
    data: 
    - objectName: ${cert_name}
      key: tls.key
    - objectName: ${cert_name}
      key: tls.crt
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityID: ${client_id}
    keyvaultName: ${keyvault_name}
    objects: |
      array:
        - |
          objectName: ${cert_name}
          objectType: secret
    tenantId: cf1fb9bf-aa93-43e6-9c9e-a8c72285c078
