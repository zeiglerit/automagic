gcloud container clusters get-credentials llm-cluster --zone us-central1-a
kubectl config rename-context gke_my-project_us-central1-a_llm-cluster llm-cluster

gcloud container clusters get-credentials sim-cluster --zone us-central1-b
kubectl config rename-context gke_my-project_us-central1-b_sim-cluster sim-cluster
