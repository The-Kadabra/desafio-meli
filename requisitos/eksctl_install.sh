cluster_name=desafio
oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
echo $oidc_id


aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4

eksctl utils associate-iam-oidc-provider --cluster $desafio 
eksctl utils associate-iam-oidc-provider --cluster $desafio --approve

####argo install
wget https://get.helm.sh/helm-v4.0.0-alpha.1-linux-amd64.tar.gz
tar -zxvf helm-v3.0.0-linux-amd64.tar.gz
