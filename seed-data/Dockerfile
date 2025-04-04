# Utilisation de l'image de base Python 3.9 slim
FROM python:3.9-slim

# Définition du répertoire de travail
WORKDIR /app

# Ajout des fichiers dans l'image
ADD . /app

# Installation de l'utilitaire ab (apache2-utils)
RUN apt-get update && apt-get install -y apache2-utils && rm -rf /var/lib/apt/lists/*

# Exécution de make-data.py lors de la construction de l'image
RUN python make-data.py

# Exécution de generate-votes.sh au démarrage du conteneur
CMD ["bash", "generate-votes.sh"]
