
# Install BookInfo Example Application

# Deploy the Services & Pod Depoyments for BookInfo

kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)


# Create the Application Gateway & Virtual Service that Routes Caller Application Traffic

kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml


# Set the INGRESS_HOST & INGRESS_PORT & Finally Set the GATEWAY_URL

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')

export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o 'jsonpath={.items[0].status.hostIP}')

export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

################# Uninstall BookInfo Application ####################
# Go to the Istio Path
cd istio-1.0.5/

#Use the ShellScript to Terminate all Resources
samples/bookinfo/platform/kube/cleanup.sh 			#Enter the namespace where you 

# Check to Make Sure All Resource are Terminated
kubectl get virtualservices   #-- there should be no virtual services
kubectl get destinationrules  #-- there should be no destination rules
kubectl get gateway           #-- there should be no gateway
kubectl get pods               #-- the Bookinfo pods should be deleted
