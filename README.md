# install-argocd
이 레포지토리는 argocd 모듈의 인스톨 가이드 입니다. 
## 폐쇄망 구축 가이드
> 아래의 가이드는, 우선적으로 외부 네트워크 통신이 가능한 환경에서 필요한 이미지들을 tar로 다운받고, 해당 tar들을 폐쇄망으로 이동시켜 작업합니다. 폐쇄망이 아니라면, 바로 마지막 단계인 "yaml 설치" 단계로 넘어가주시길 바랍니다

* 작업 디렉토리 생성 및 환경 변수 설정
```
mkdir -p ~/argocd-install
export ARGOCD_WORKDIR=~/argocd-install
```

* 이미지 환경 변수 설정
    * 아래는 v2.2.5 기준 가이드입니다
```
export ARGOCD_IMG_URL=quay.io/argoproj/argocd:v2.2.5
export DEX_IMG_URL=ghcr.io/dexidp/dex:v2.30.2
export REDIS_IMG_URL=redis:6.2.6-alpine
```
* 작업 디렉토리로 이동
```
cd $ARGOCD_WORKDIR
```
* 외부 네트워크 통신이 가능한 환경에서 필요한 이미지 다운로드
```
sudo docker pull $ARGOCD_IMG_URL
sudo docker save $ARGOCD_IMG_URL > argocd.tar

sudo docker pull $DEX_IMG_URL
sudo docker save $DEX_IMG_URL > dex.tar

sudo docker pull $REDIS_IMG_URL
sudo docker save $REDIS_IMG_URL > redis.tar
```
* 레지스트리 환경 변수 설정
```
export REGISTRY=registryip:port
```

* 생성한 이미지 tar 파일을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 push.
```
sudo docker load < argocd.tar
sudo docker tag $ARGOCD_IMG_URL ${REGISTRY}/argoproj/argocd:v2.2.5
sudo docker push ${REGISTRY}/argoproj/argocd:v2.2.5

sudo docker load < dex.tar
sudo docker tag $DEX_IMG_URL ${REGISTRY}/dexidp/dex:v2.30.2
sudo docker push ${REGISTRY}/dexidp/dex:v2.30.2

sudo docker load < redis.tar
sudo docker tag $REDIS_IMG_URL ${REGISTRY}/redis:6.2.6-alpine
sudo docker push ${REGISTRY}/redis:6.2.6-alpine
```

* 레지스트리에 푸시된 이미지들을 install_v2.2.5.yaml에 반영
```
sed -i "s/quay.io/${REGISTRY}/g" install_v2.2.5.yaml		 	 
sed -i "s/ghcr.io/${REGISTRY}/g" install_v2.2.5.yaml		 
sed -i "s/redis:6.2.6-alpine/${REGISTRY}\/redis:6.2.6-alpine/g" install_v2.2.5.yaml		 
```

* yaml 설치 (폐쇄망이 아닌 환경이라면, 여기서 부터 진행할 것)
```
kubectl create namespace argocd
kubectl apply -n argocd -f install_v2.2.5.yaml
```
 
## ArgoCD Server에 접근
기본적으로 ArgoCD API Server는 external IP로 노출이 되지 않기 때문에, ArgoCD Server에 UI로 접근하려면 argocd-server 서비스의 타입을 변경해주거나 argocd-server 서비스를 ingress와 연동하는 등의 추가 작업을 해야 합니다. 

### Ingress로 노출
* 아래는 ingress를 이용하는 방법입니다. 
* ingress.yaml 내 spec.rules.host 필드를 적당한 DNS로 대체하여 ingress 리소스를 생성합니다.
* (유의) Hyperauth 연동을 할 예정이면, 이 단계를 건너 뛰고 Hyperauth 연동 docs를 참고할 것 (docs/Hyperauth 연동 가이드.md 참고)
```
kubectl apply -n argocd -f ingress.yaml
```
## Self-signed gitlab 연동
env들을 수정하여 [gen-gitlab-repo-secret.sh](https://github.com/tmax-cloud/install-argocd/blob/main/gen-gitlab-repo-secret.sh) 실행 및 [gitlab self-signed 가이드](https://github.com/tmax-cloud/install-argocd/blob/main/docs/gitlab%20self-signed%20%EA%B0%80%EC%9D%B4%EB%93%9C.md) 참고

## HyperAuth 연동
[OIDC 연동 가이드](https://github.com/tmax-cloud/install-argocd/blob/main/docs/OIDC%20%EC%97%B0%EB%8F%99%20%EA%B0%80%EC%9D%B4%EB%93%9C.md)

## admin 초기 비밀번호 및 비밀번호 재설정
1. admin 계정의 초기 비밀번호 얻어오기
- argocd 설치 시, super 계정인 admin 계정은 자동으로 생성됩니다. 
- admin 계정의 초기 비밀번호는 auto-gen되어 argocd 네임스페이스 내 시크릿 argocd-initial-admin-secret에 저장됩니다. 따라서 아래의 kubectl 커맨드로 우선 password을 얻어옵니다.
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
2-1. (추천) UI를 통해 비밀번호 재설정하는 방법

![image](https://user-images.githubusercontent.com/36444454/150266598-0d97a399-7d36-4205-9a45-e93cce0e6650.png)
- 1) 브라우저로 ArgoCD UI 접속
- 2) Username: admin / Password: 위에서 얻어온 초기 비밀번호 기입하여 로그인
- 3) 홈화면의 왼쪽 사이드 'User Info' 아이콘 클릭
- 4) 왼쪽 상단 위에 "UPDATE PASSWORD"를 눌러 비밀번호 재설정 
- 유의 : 비밀번호 규격 지킬 것 (8~32자 이내로)

2-2. kubectl을 통해 비밀번호 재설정하는 방법
1. bcrypt을 이용하여 새로운 비밀번호에 대한 새로운 hash 값을 생성합니다.
- brcrypt 사이트 추천 : https://www.browserling.com/tools/bcrypt 
2. 새로운 hash 값으로 argocd-secret을 patch 시켜줍니다.
```
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "{새로운 비밀번호에 대한 해쉬값을 여기 넣어주세요}",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'
```
