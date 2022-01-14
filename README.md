# install-argocd
## 폐쇄망 구축 가이드
> 아래의 가이드는, 우선적으로 외부 네트워크 통신이 가능한 환경에서 필요한 이미지들을 tar로 다운받고, 해당 tar들을 폐쇄망으로 이동시켜 작업합니다. 

* 작업 디렉토리 생성 및 환경 변수 설정
```
mkdir -p ~/argocd-install
export ARGOCD_WORKDIR=~/argocd-install
```

* 이미지 환경 변수 설정
    * 유의할 점 : latest에 반영된 dex 이미지와 redis 버전 체크.
```
export ARGOCD_IMG_URL=quay.io/argoproj/argocd:latest
export ARGOCD_NOTIFICATION_IMG_URL=argoprojlabs/argocd-notifications:latest
export DEX_IMG_URL=ghcr.io/dexidp/dex:v2.30.0
export REDIS_IMG_URL=redis:6.2.4-alpine
```
* 작업 디렉토리로 이동
```
cd $ARGOCD_WORKDIR
```
* 외부 네트워크 통신이 가능한 환경에서 필요한 이미지 다운로드
```
sudo docker pull ARGOCD_IMG_URL
sudo docker save ARGOCD_IMG_URL > argocd.tar

sudo docker pull ARGOCD_NOTIFICATION_IMG_URL
sudo docker save ARGOCD_NOTIFICATION_IMG_URL > argocd-notification.tar

sudo docker pull DEX_IMG_URL
sudo docker save DEX_IMG_URL > dex.tar

sudo docker pull REDIS_IMG_URL
sudo docker save REDIS_IMG_URL > redis.tar
```
* 레지스트리 환경 변수 설정
```
export REGISTRY=registryip:port
```

* 생성한 이미지 tar 파일을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 push.
```
sudo docker load < argocd.tar
sudo docker tag ARGOCD_IMG_URL ${REGISTRY}/argocd:latest
sudo docker push ${REGISTRY}/argocd:latest

sudo docker load < argocd-notification.tar
sudo docker tag  ARGOCD_NOTIFICATION_IMG_URL ${REGISTRY}/argocd-notifications:latest
sudo docker push ${REGISTRY}/argocd-notifications:latest

sudo docker load < dex.tar
sudo docker tag DEX_IMG_URL ${REGISTRY}/dex:v2.30.0
sudo docker push ${REGISTRY}/dex:v2.30.0

sudo docker load < redis.tar
sudo docker tag REDIS_IMG_URL ${REGISTRY}/redis:6.2.4-alpine
sudo docker push ${REGISTRY}/redis:6.2.4-alpine
```

* 레지스트리에 푸시된 이미지들을 install.yaml에 반영
```
sed -i "s/quay.io\/argoproj/${REGISTRY}/g" install.yaml		 
sed -i "s/argoprojlabs/${REGISTRY}/g" install.yaml		 
sed -i "s/ghcr.io\/dexidp/${REGISTRY}/g" install.yaml		 
sed -i "s/redis:6.2.4-alpine/${REGISTRY}\/redis:6.2.4-alpine/g" install.yaml		 
```

* yaml 설치
```
kubectl create namspace argocd
kubectl apply -n argocd -f install.yaml
```
