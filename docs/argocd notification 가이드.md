# Argo CD Notifications 가이드
## ArgoCD Notifications 이란?
- Argo CD에서 관리되는 Application 상태의 중요한 변경사항을 알려주는 라이브러리
- 현재 다양한 알림 채널을 지원 중(Email, Slack, Grafana, Teams, Webhook 등)
- 이 라이프러리 외에도 Argo CD Application의 상태를 모니터링 할 수 있는 방법은 여러 가지 있으나 상대적으로 이 프로젝트가 use case도 훨씬 다양하고, UX적으로 뛰어나단 평가를 받음
  -  다른 방법 : bitnami-labs/kubewatch, argo-kube-notifier

## 설치 전 준비사항
- 쿠버네티스 클러스터에 ArgoCD가 설치되어 있어야 한다. 
  - 같은 네임스페이스에 설치시켜줘야 함

## 설치
- argocd가 설치되어 있는 네임스페이스에 argocd-notifications 설치 (manifests 디렉토리 아래 있음)
- argocd-notifications-controller-{랜덤 스트링...} pod가 Running 상태인지 확인
```
kubectl apply -n argocd -f argocd-notifications.yaml
```



