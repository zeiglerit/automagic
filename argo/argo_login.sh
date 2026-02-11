#!/bin/bash
#
export PASS=$(kubectl -n argocd get secret argocd-initial-admin
-secret \                                       
  -o jsonpath="{.data.password}" | base64 -d) && echo $PASS && argocd login localhost:8080 --username admin --password $PASS --insecure
