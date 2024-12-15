#!/bin/bash

kubectl create namespace airflow || true
docker build -t 2024_kubernetes_post_pusher -f ./post_pusher/Dockerfile .
docker build -t 2024_kubernetes_post_consumer -f ./post_consumer/Dockerfile .

kubectl apply -f ./airflow/airflow-dags-pv.yaml 
kubectl apply -f ./airflow/airflow-dags-pvc.yaml 

helm repo add airflow-stable https://airflow-helm.github.io/charts
helm install airflow airflow-stable/airflow --namespace airflow --version 8.9.0 --values ./airflow/custom-values.yaml 
kubectl port-forward svc/airflow-web 8080:8080 --namespace airflow

kind delete cluster || true
kind create cluster --config ./kind/config.yaml

kind load docker-image 2024_kubernetes_post_pusher
kind load docker-image 2024_kubernetes_post_consumer  

kubectl apply -f cours_kafka/kafka/service.yaml
kubectl apply -f cours_kafka/kafka/deployment.yaml 

kubectl apply -f cours_kafka/ui/configmap.yaml
kubectl apply -f cours_kafka/ui/service.yaml
kubectl apply -f cours_kafka/ui/deployment.yaml

kubectl apply -f post_pusher/deployment.yaml 
kubectl apply -f post_consumer/deployment.yaml 