apiVersion: v1
preferences: {}
kind: Config

clusters:
- cluster:
    server: ${endpoint}
    certificate-authority-data: ${cluster_auth_base64}
  name: ${kubeconfig_name}

contexts:
- context:
    cluster: ${kubeconfig_name}
    user: ${kubeconfig_name}
  name: ${kubeconfig_name}

current-context: ${kubeconfig_name}

users:
- name: ${kubeconfig_name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
        - --region
        - ${region}
        - eks
        - get-token
        - --cluster-name
        - ${clustername}
      command: C:\Program Files\Amazon\AWSCLIV2\aws.exe
      env: null
      interactiveMode: IfAvailable
      provideClusterInfo: false
