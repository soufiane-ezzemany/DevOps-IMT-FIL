# Docker Voting Application

Ce projet implémente une application de vote en utilisant Docker et Docker Compose.

## Architecture

L'application est composée des services suivants :
- **vote1 & vote2** : Interfaces web Python (Flask) permettant aux utilisateurs de voter
- **redis** : Base de données NoSQL pour stocker les votes
- **worker** : Service .NET qui traite les votes et les enregistre dans la base de données
- **db** : Base de données PostgreSQL pour stocker les résultats
- **result** : Interface web Node.js affichant les résultats des votes
- **nginx** : Répartiteur de charge qui distribue les requêtes entre les services vote1 et vote2
- **seed** : Service d'injection de données pour simuler des votes

## Réseaux

L'application utilise deux réseaux Docker distincts :
- **back-tier** : Réseau interne pour les communications entre services (db, redis, vote, result, worker)
- **front-tier** : Réseau exposé pour les interfaces utilisateur (nginx, vote, result)

## Volumes

- **db-data** : Volume persistant pour les données PostgreSQL

## Healthchecks

Des scripts de healthcheck sont implémentés pour les services suivants :
- **db** : Vérifie l'état de PostgreSQL
- **redis** : Vérifie l'état de Redis

## Déploiement

### Prérequis
- Docker
- Docker Compose

### Installation et démarrage

1. Clonez ce dépôt :
```bash
git clone <repository-url>
cd <repository-directory>
```

2. Démarrez l'application avec Docker Compose :
```bash
docker-compose up -d
```

3. Accédez à l'interface de vote :
```
http://localhost:80
```

4. Accédez à l'interface des résultats :
```
http://localhost:3000
```

### Arrêt de l'application

```bash
docker-compose down
```

Pour supprimer également le volume persistant :
```bash
docker-compose down -v
```

## Structure des services

### Vote (vote1 & vote2)
Services Python Flask permettant aux utilisateurs de voter pour l'option A (Cats) ou l'option B (Dogs).

### Redis
Service de cache pour stocker temporairement les votes avant traitement.

### Worker
Service .NET qui récupère les votes depuis Redis et les enregistre dans la base de données PostgreSQL.

### DB (PostgreSQL)
Base de données persistante stockant les résultats des votes.

### Result
Interface web Node.js qui affiche les résultats des votes en temps réel.

### Nginx
Répartiteur de charge qui distribue les requêtes entre les services vote1 et vote2.

### Seed
Service qui simule des votes pour tester l'application. 


# Kubernetes Voting Application

Ce projet implémente le déploiement de l'application de vote sur un cluster Kubernetes.

## Architecture

L'application est déployée sur Kubernetes avec les composants suivants :
- **vote** : Déploiement de l'interface de vote (3 réplicas avec autoscaling)
- **result** : Déploiement de l'interface des résultats
- **worker** : Déploiement du service de traitement des votes
- **redis** : Déploiement et service pour la base de données Redis
- **db** : Déploiement et service pour la base de données PostgreSQL avec volume persistant
- **seed** : Job Kubernetes pour injecter des données de test

## Scripts d'automatisation

Pour faciliter le déploiement, deux scripts shell ont été développés :

### 1. generate-images-services.sh
Ce script automatise la création et le chargement des images Docker dans Minikube :
```bash
./generate-images-services.sh
```

Le script :
- Construit les images Docker pour les services (vote, result, worker, seed-data)
- Charge ces images dans Minikube

### 2. apply-k8s.sh
Ce script applique les manifestes Kubernetes dans l'ordre approprié :
```bash
./apply-k8s.sh
```

Le script :
- Déploie la base de données PostgreSQL avec son volume persistant
- Déploie le service Redis
- Déploie le worker
- Déploie les services vote et result
- Applique le job de génération de données
- Lance le tunnel Minikube pour exposer les services

## Caractéristiques principales

### Persistance des données
- Un PersistentVolume (PV) et PersistentVolumeClaim (PVC) sont configurés pour PostgreSQL
- La configuration utilise subPath pour préserver les données même en cas de suppression du pod

### Healthchecks
- Des livenessProbes sont configurés pour tous les services
- Les services db et redis utilisent des scripts de healthcheck via des initContainers
- Les services vote et result utilisent des healthchecks HTTP

### Autoscaling
- Le service vote est configuré avec un HorizontalPodAutoscaler
- Le scaling est basé sur l'utilisation CPU (seuil à 50%)
- Configuration : 1 à 5 réplicas

## Déploiement manuel

Si vous préférez un déploiement manuel plutôt que d'utiliser les scripts :

1. Construire et charger les images dans Minikube :
```bash
# Pour chaque service
docker build -t <service>:latest ./<service>
minikube image load <service>:latest
```

2. Appliquer les manifestes Kubernetes :
```bash
# Base de données avec volume persistant
kubectl apply -f db-service-deployment-volume.yaml

# Redis
kubectl apply -f redis-service-deployment.yaml

# Worker
kubectl apply -f worker/deployment.yaml

# Vote
kubectl apply -f vote/deployment.yaml
kubectl apply -f vote/service.yaml
kubectl apply -f vote/horizontalpodautoscaler.yml

# Result
kubectl apply -f result/deployment.yaml
kubectl apply -f result/service.yaml

# Seed job
kubectl apply -f seed-data/job.yaml
```

3. Créer un tunnel pour accéder aux services :
```bash
minikube tunnel
```

## Accès aux applications

- Interface de vote : http://localhost (Service LoadBalancer)
- Interface des résultats : http://localhost:3000

## Test de charge

Un script de test de charge est disponible pour tester l'autoscaling :
```bash
./vote/load-test.sh
```

## Nettoyage

Pour supprimer toutes les ressources :
```bash
kubectl delete -f <manifest-files>
```

Ou pour supprimer toutes les ressources avec le label app=vote :
```bash
kubectl delete all -lapp=vote
``` 