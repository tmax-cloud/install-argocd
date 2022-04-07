# SSO가 아닌 ArgoCD local user를 추가하는 가이드
- 목적 : CLI에서 sso 로그인을 지원하지 않고 있음. 따라서 CLI에서만 가능한 기능들은 local user를 이용해야함. (전체 ArgoCD 리소스에 대한 액세스 권한이 있는 슈퍼 유저 계정인 admin은 초기 구성에만 사용하고 사용하지 않는 걸 권장) 
- 유의사항 : 
  - 서비스 단위로 권한 부여하는 걸 권장.
(서비스 example1는 로컬 유저 my-team만 접근 가능하게. 서비스 example2는 로컬 유저  user2만 접근 가능하게)
  - 컨피그맵 특성상 100MB 제한이 있어서, user를 과잉 추가하는 건 적절치 않음. 작은 규모의 팀에서 사용하길 권장

크게 1) local user 추가  2) 각 local user의 rbac 규칙 설정하는 단계로 구성됨 
## 1. Local User 추가
- 네임스페이스 argocd 내 컨피그맵 argocd-cm을 수정해야 함 (해당 컨피그맵은 argocd 설치 시 같이 생성됨)
```
kubectl edit configmap -n argocd argocd-cm
```
- 각 local user는 두 가지 기능 소유 가능
  - apiKey : API 엑세스를 위한 인증 토큰 생성 허용
  - login : UI로 로그인 허용
- 추가 사용자가 생성되는 즉시, admin은 비활성화하는 걸 권장
- 아래 예시 참고
  - apiKey와 login 기능을 가진 my-team 이라는 로컬 유저 생성
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
data:
  # add an additional local user with apiKey and login capabilities
  #   apiKey - allows generating API keys
  #   login - allows to login using UI
  accounts.my-team: apiKey, login
  # disables user. User is enabled by default
  # accounts.my-team: "false"
  # disables admin.
  # admin.enabled: "false"
```
- local user 비밀번호 설정
  - 아래 \<current-user-passord\> 자리에 admin 계정 비밀번호 넣어줘야 함
```
# if you are managing users as the admin user, <current-user-password> should be the current admin password.
argocd account update-password \
  --account <name> \
  --current-password <current-user-password> \
  --new-password <new-user-password>
```
## 2. 각 local user의 rbac 규칙 설정
- rbac 기능을 사용하면 ArgoCD 리소스에 대한 액세스 제한 가능 
- 네임스페이스 argocd 내 컨피그맵 argocd-rbac-cm 수정 필요(해당 컨피그맵은 argocd 설치 시 같이 생성됨)

- RBAC 리소스 및 잡
  - 리소스 : clusters, projects, applications, repositories, certificates, accounts,gpgkeys
  - 작업 : get, create, update, delete, sync, override,action

- 아래 예시 설명
  - my-team-admin 롤(role)은 my-team이라는 local user에게 할당된다.
  - my-team-admin 롤은, 모든 프로젝트에 'guestbook'라는 appliction 리소스에 모든 잡을 행할 수 있는 권한이 허용된다.
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.default: role:readonly
  policy.csv: |
    p, role:my-team-admin, applications, *, */guestbook, allow

    g, my-team, role:my-team-admin
```

