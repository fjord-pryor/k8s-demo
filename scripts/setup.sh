#!/usr/bin/env bash
gcloud init

gcloud config set compute/region us-east1
gcloud config set compute/zone us-east1-c

gcloud config set project elite-vault-341617

gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# make create
