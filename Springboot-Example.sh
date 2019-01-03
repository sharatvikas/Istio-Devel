
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

