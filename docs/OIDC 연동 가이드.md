# gatekeeper를 통한 Hyperauth(keycloak) 연동 가이드
traefik을 사용하여 gatekeeper와 연동하는 임시 가이드입니다. 
## 지원 목적
* ArgoCD에서 자체적으로 keycloak과의 연동을 지원해주고 있지만, hyperauth를 쓰는 다른 서비스들과의 통일성을 위해 사용 불가.
* ArgoCD 내에서 keycloak 연동 시, 'Client Scopes > groups (따로 생성해야 함)'을 사용하는 데, hyperauth를 쓰는 다른 연동 서비스들은 "client - client role"을 사용해서 권한 관리를 하고 있기 때문에, 아래는 이 정책을 따르기 위한 가이드임.

## Prerequisite
* argocd installed
* traefik installed
* cert-manager installed
* hyperauth installed and Realm Tmax existed

## 연동 가이드 (/gatekeeper 내 파일 참조)
### 1. Hyperauth 내 Client 생성 및 관리자 계정 role 매핑 
* 1-1) hyperauth에서 'argocd' client 생성
    * Client protocol : openid-connect
    * Access type: confidential
* 1-2) client / argocd / credentials : secret을 따로 메모장에 복사할 것
* 1-3) client / argocd / roles / argocd-manager client role 생성
    * argocd-manager client role을 가진 user만 client 서비스에 로그인 가능
* 1-4) 관리자 계정 / role mappings / client roles : argocd에서 생성한 role인 argocd-manager를 부여.
* 1-5) client / argocd / Mappers / Create 생성
    * Name: argocd 기입
    * Mapper Type : Audience 선택
    * Included Client Audience : argocd 선택
    * Access to access token : 'ON' 선택
        * Access Token Audience에 argocd를 포함시키기 위함
### 2. Configmap 'gatekeeper-files' 생성
* gatekeeper/argocd-gatekeeper-forbidden-cm.yaml 참고
* 접근불가 시, 뜨는 html 페이지 정보를 담고 있음
* html 마지막 Logout 태그에 redirect 주소를 실제 노출로 주소로 변경해줘야 한다.
* "https://argocd.ckcloud.org" 부분 변경(포트는 그대로 3000 유지)하고 apply.
```
kubectl apply -f argocd-gatekeeper-forbidden-cm.yaml
```
### 3. Deployment 'argocd-server' 대체
* gatekeeper/argocd-server-deployment.yaml로 기존 리소스 대체
* gatekeeper 컨테이너 내, client-secret 수정할 것
```
kubectl apply -f argocd-server-deployment.yaml
```
### 4. Service 'argocd-server' 대체
```
kubectl apply -f argocd-server-svc.yaml
```

### 5. IngressRoute 'argocd-server'생성
```
kubectl apply -f ingress-route.yaml
```

### 6. Certificate 생성
```
kubectl apply -f certificate.yaml
```

### 7. Configmap 'argocd-cm' 대체
```
kubectl apply -f argocd-cm.yaml
```
