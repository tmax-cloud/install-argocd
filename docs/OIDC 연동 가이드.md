# OIDC 연동 가이드 
## Prerequisite
* argocd installed
* hyperauth installed and Realm Tmax existed

## 연동 가이드
### 1. Hyperauth 내 Client 생성 및 관리자 계정 셋팅
* 1-1) tmax Realm을 선택 후, 'argocd' client 생성 (Clients > Create 버튼 클릭)
    * Client ID : argocd
    * Client protocol : openid-connect
    * Root URL : argocd hostname 입력 (예 - https://argocd.example.com)
* 1-2) client 생성 후, argocd 상세페이지에서 아래처럼 항목 선택 및 기입
    * Access type: confidential
    * Valid Redirect URIs : *
* 1-3) 'Save' 클릭 후, 생성된 Credentials 탭에 가서 secret 복사
* 1-4) groups 라는 새로운 Client Scope 생성 (Client Scopes > Create 버튼 클릭)
    * Name : groups
* 1-5) Token Mapper 생성 (Client Scopes > groups > Mappers 탭에서 Create 클릭)
    * Name : groups
    * Mapper Type: Group Membership
    * Token Claim Name: groups
* 1-6) 클라이언트 argocd에 groups 스코프 할당 (Clients > argocd > Client Scopes)
    * Default Client Scopes 목록에서 groups를 선택하여 'Add selected >>' 버튼 클릭
* 1-7) 'argocd-admin' 그룹 생성(Groups에서 New 클릭)
    * Name: argocd-admin
* 1-8) argocd 접근을 부여하고자하는 관리자 계정에 'argocd-admin' 그룹 멤버쉽 부여 (Users > '관리자계정' 클릭 > Groups > Available Groups 리스트 내 argocd-admin 선택 후 Join 클릭)
### 2. 1-3 단계에서 복사한 Client Secret을 argocd-secret에 적용
* 2-1) 복사한 secret을 base64로 인코딩 (아래 예시 참고)
```
echo -n '83083958-8ec6-47b0-a411-a8c55381fbd2' | base64
```
* 2-2) argocd-secret 내 data에 oidc.keycloak.clientSecret 필드 추가
    * 위에서 인코딩한 secret을 oidc.keycloak.clientSecret 필드의 값으로 기입 (아래 참고)
```
kubectl edit secret argocd-secret -n argocd
# argocd-secret에 data 내 oidc.keycloak.clientSecret
# apiVersion: v1
# kind: Secret
# metadata:
#   name: argocd-secret
# data:
#   ...
#   oidc.keycloak.clientSecret: ODMwODM5NTgtOGVjNi00N2IwLWE0MTEtYThjNTUzODFmYmQy   
#   ...
```
### 3. Configmap 'argocd-cm' 내 OIDC config 추가
```
kubectl edit configmap argocd-cm -n argocd
```
argocd, hyperauth hostname으로 각각 url, issuer 수정할 것
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
data:
  url: https://argocd.example.com
  oidc.config: |
    name: Keycloak
    issuer:  https://hyperauth.example.com/auth/realms/tmax
    clientID: argocd
    clientSecret: $oidc.keycloak.clientSecret
    requestedScopes: ["openid", "profile", "email", "groups"]
```
### 4. Configmap 'argocd-rbac-cm' 내 argocd policy 추가
```
 kubectl edit configmap argocd-rbac-cm -n argocd
```
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
data:
  policy.csv: |
    g, argocd-admin, role:admin
```

### 5. Login via keycloak 
