param ()

Push-Location (Join-Path $PSScriptRoot "chart" "templates")

kubectl create namespace sam
kubectl create namespace sam-secret
kubectl apply -f private-azure-file-sc.yaml -n sam
kubectl apply -f private-pvc.yaml -n sam
kubectl apply -f nginx-pod-azurefile.yaml -n sam

# kubectl describe pvc/demo-app-pvc -n sam
# kubectl describe pod/nginx-azurefile -n sam

# kubectl exec --stdin --tty nginx-azurefile -n sam -- /bin/bash 
# kubectl run -it --rm aks-ingress-test --image=mcr.microsoft.com/dotnet/runtime-deps:6.0 --namespace space48

Pop-Location