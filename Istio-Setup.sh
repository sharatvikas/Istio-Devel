#Istio Installation & Configuration

# Setup Proxy to Download Latest Istio Version
export HTTP_PROXY="http://proxy.ebiz.verizon.com:80/"
export HTTPS_PROXY="http://proxy.ebiz.verizon.com:80/"

#Curl to Download the Latest Istio
curl -L https://git.io/getLatestIstio | sh -

#Set the istioctl PATH
export PATH="$PATH:/home/k8suser/istio-1.0.5/bin"

#Unset Proxy before Continuing
unset HTTP_PROXY
unset HTTPS_PROXY

# Make Changes to install/kubernetes/helm/istio/values.yaml
# CHange IngressGateway from LoadBalancer -> NodePort
# Enable All Addons like Telemetry, ServiceGraph, Kiali, Jaeger
# Grafana, Prometheus & Disable Galley
vi install/kubernetes/helm/istio/values.yaml

# Create a Helm Template
helm template install/kubernetes/helm/istio --name istio --namespace istio-system > $HOME/istio.yaml

# Istio has Custom Resource Definitions (CRDs) to Create Gateway Routing etc.
kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml

# Create the Istio-System Namespace
kubectl create namespace istio-system

#Apply the Helm Template
kubectl apply -f $HOME/istio.yaml

#Check your Istio-System Pods & Services to Verify All Istio Enabled Services
kubectl get svc -n istio-system
watch -n 1 kubectl get pods -n istio-system

# Change Service Types like Kiali, ServiceGraph & Jaeger-query to NodePort
# This Allows you to see the Dashboard for these Services 

kubectl edit svc kiali -n istio-system

kubectl edit svc servicegraph -n istio-system

kubectl edit svc jaeger-query -n istio-system

#Check your Istio-System Pods & Services to Verify All Istio Enabled Services
kubectl get svc -n istio-system

############ Istio Install Complete ##############