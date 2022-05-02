# Argo CD Notifications 가이드
## ArgoCD Notifications 이란?
- Argo CD에서 관리되는 Application 상태의 중요한 변경사항을 알려주는 라이브러리
- 현재 다양한 알림 채널을 지원 중(Email, Slack, Grafana, Teams, Webhook 등)
- 이 라이프러리 외에도 Argo CD Application의 상태를 모니터링 할 수 있는 방법은 여러 가지 있으나 상대적으로 이 프로젝트가 use case도 훨씬 다양하고, UX적으로 뛰어나단 평가를 받음
  -  다른 방법 : bitnami-labs/kubewatch, argo-kube-notifier

## 설치 전 준비사항
- 쿠버네티스 클러스터에 ArgoCD가 설치되어 있어야 한다. 
  - 같은 네임스페이스에 설치시켜줘야 함

## Argo CD Notifications 설치
- argocd가 설치되어 있는 네임스페이스에 argocd-notifications 설치 (manifests 디렉토리 아래 있음)
  - argocd-notifications-controller-{랜덤 스트링...} pod가 Running 상태인지 확인
```
kubectl apply -n argocd -f argocd-notifications.yaml
```
## Triggers & Template 설치
```
kubectl apply -n argocd -f argocd-notifications-cm.yaml
```
## Slack 연동 가이드
### Slack 설정
1. Slack 애플리케이션을 생성 (https://api.slack.com/apps?new_app=1)
- Create an App > From scratch를 눌러 생성
- 적당한 App Name과 워크스페이스를 선택
2. 애플리케이션 생성 후, 화면이 이동되면 좌측 메뉴바에 보이는 "OAuth & Permissions" 클릭
3. 해당 페이지의 하단에 Scopes > Bot Token Scopes에서 Add an OAuth Scope 를 누르고, chat:write 를 입력해서 새로운 OAuth scope을 생성
4. 페이지 최상단으로 올라와 "Install to Workspace"을 눌러 OAuth Token을 워크스페이스에 등록. 확인을 요청하는 페이지가 나타나면 "허용" 클릭
5. 생성된 Bot User OAuth Token을 메모장에 복사
6. Slack을 열어 알림을 전송할 워크스페이스 채널에 위에서 만든 bot을 초대. 채널 세부 정보 열기에서 통합 메뉴를 누르고 앱 추가를 해줌
### Argo CD Notifiactions 설정
1. Slack 설정 과정에서 생성한 토큰을 ArgoCD Notification에 등록해야함
- 다음의 내용 argocd-notifications-secret.yaml 파일로 생성하고 argocd 네임스페이스에 apply 해줌
```
# argocd-notifications-secret.yaml 
apiVersion: v1 
kind: Secret 
metadata: 
  name: argocd-notifications-secret 
stringData:
  slack-token: <여기에 Slack에서 만든 토큰 기입>
```
```
kubectl apply -f argocd-notifications-secret.yaml -n argocd
```
2. 네임스페이스 argocd의 argocd-notifications-cm을 수정
```
 kubectl edit cm argocd-notifications-cm -n argocd
```
다른 내용은 건드리지 않고, 아래 token만 넣어주고 빠져나올 것
```
apiVersion: v1 
kind: ConfigMap 
metadata: 
    name: argocd-notifications-cm 
data: 
    service.slack: | 
      token: <여기에 토큰을 입력> ...
``` 
3. 모니터링할 Application의 annotations 수정
- 예시) sync가 성공했을 때 알림 설정
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    notifications.argoproj.io/subscribe.on-sync-succeeded.slack: <여기에 알람을 받을 채널 이름 기입>
```
### 알림을 받고 싶은 상태 설정
- Sync가 성공했을 때 알림
```
notifications.argoproj.io/subscribe.on-sync-succeeded.slack: <슬랙 채널 이름>
```
- Sync가 실패했을 때 알림
```
notifications.argoproj.io/subscribe.on-sync-failed.slack: <슬랙 채널 이름>
```
- Sync가 진행중일 때 알림
```
notifications.argoproj.io/subscribe.on-sync-running.slack: <슬랙 채널 이름>
```
- Sync 상태가 Unknown일 떄 알림
```
notifications.argoproj.io/subscribe.on-sync-status-unknown.slack: <슬랙 채널 이름>
```
- Health가 Degrade 되었을 때 알림
```
notifications.argoproj.io/subscribe.on-health-degraded.slack: <슬랙 채널 이름>
```
- Deploy 되었을 때 알림
```
notifications.argoproj.io/subscribe.on-deployed.slack: <슬랙 채널 이름>
```

## Email 연동 가이드
Email은 SMTP 프로토콜을 사용하여서 아래의 정보를 가지고 argocd-notifications-cm을 수정해줘야 함
- host - the SMTP server host name
- port - the SMTP server port
- username - username
- password - password
- from - from email address

Example. Gmail을 사용할 경우
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
data:
  service.email.gmail: |
    username: $email-username
    password: $email-password
    host: smtp.gmail.com
    port: 465
    from: $email-username
```

Slack과 마찬가지로, 모니터링할 Application의 annotations 수정
Example. Gmail을 사용할 경우, 
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    notifications.argoproj.io/subscribe.on-sync-succeeded.gmail: <여기에 알람을 받을 gmail 주소>
```
on-sync-succeeded 외 상태는 위에 참고

### Gmail 유의사항
- gmail 설정에서 보안수준이 낮은 앱에 대한 액세스를 허용해야 함
