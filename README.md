# Istio-Devel
Istio Configuration &amp; Deploying a Example Springboot Application

#Curl to Download the Latest Istio
curl -L https://git.io/getLatestIstio | sh -

#Set the istioctl PATH
export PATH="$PATH:/home/k8suser/istio-1.0.5/bin"

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


########### Install SpringBoot Application using Istio ##################

# Use "istioctl kube-inject" to init & attach the Sidecar-Proxy Container (istio-proxy)

# Deploy the Services for Caller/Callme & Pod Depoyments for caller & callme-v1/callme-v2
kubectl apply -f <(istioctl kube-inject springboot-example/call-deployment.yaml)

#Check the Services & Pods are Running
watch -n 1 kubectl get pods
kubectl get svc

# To Access the Service from Web you need a Load-Balancer/NodePort
# Add the Application Ports into the Istio-IngressGateway to Create a NodePort
kubectl get svc -n istio-system

kubectl edit svc istio-ingressgateway -n istio-system

  port: 8090
  targetPort: 8090
  name: http-caller
  
  port: 8091
  targetPort: 8091
  name: http-callme

# Try Accessing the Application using these NodePorts on the Istio-IngressGateway
# Example: 10.119.40.92:31013/caller/ping

<NodeIP>:<NodePort>/caller/ping

# Istio does not allow traffic until you Create an Application Gateway That Opens Traffic to Your Application
# To Route Traffic from the IngressGateway to your Application (Through your Application Gateway) - Use "VirtualService" that define the Path (/caller/ping)

# Create the Application Gateway & Virtual Service that Routes Caller Application Traffic
kubectl apply -f springboot-example/call-app-gateway.yaml

# Using DestinationRules you can Define Which Version You want to Route Your Application Traffic
kubectl apply -f springboot-example/call-destination-rules-all.yaml

# Try Accessing the Application using these NodePorts on the Istio-IngressGateway
# Example: 10.119.40.92:31013/caller/ping
<NodeIP>:<NodePort>/caller/ping
 
############ Application Deploy Complete ##############

######## Check the Traffic on Sidecar-Proxy ###########

# Check the Traffic is Routed through the Sidecar-Proxy
kubectl get pods

# View the Istio-Proxy Logs
kubectl logs pod caller-service-54cf7b65b4-2ck7d istio-proxy

# View the caller-service Logs
kubectl logs pod caller-service-54cf7b65b4-2ck7d caller-service

###### Check to make sure that the Inbound and OutBound Calls are from the Istio-Proxy Logs #########
