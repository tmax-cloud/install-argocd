# Gitlab self-signed repository 가이드
## 목적
gitlab에 공인인증서가 아닌 self-signed 인증서를 사용할 경우, argocd에 git repo 정보를 등록해줘야 하는데, argocd 설치 시 이를 등록시켜주려 함
## 1. repo-secret-yaml.form 참고하여, repo secret 매니페스트 작성
각 필드에 맞는 값들을 base64 인코딩해서 넣어주면 됨.
아래 repo-secret-yaml.form 참고
```
apiVersion: v1
kind: Secret
metadata:
  annotations:
    managed-by: argocd.argoproj.io
  labels:
    argocd.argoproj.io/secret-type: repository
  name: repo-325531515 # 수정 (gen-secret-name.py 실행해서 나온 값)
  namespace: argocd
type: Opaque
data:
  insecure: dHJ1ZQ==
  project: ZGVmYXVsdA== 
  type: Z2l0 
  url: aHR0cHM6Ly9naXRsYWIuZ2l0bGFiLXN5c3RlbS4xNzIuMjEuNS4yMTAubmlwLmlvL3Jvb3QvYXJnb2NkLWluc3RhbGxlci5naXQ= # 수정
  username: YWRtaW5AZXhhbXBsZS5jb20= # 수정  
  password: cXdlcjEyMzQ1IQ== # 수정
  tlsClientCertKey: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUVEa... # 수정

```
- secret의 name은 gen-secret-name.py 실행하여 나온 결과값을 기입할 것
  - [gen-secret-name.py](https://github.com/tmax-cloud/install-argocd/blob/d94c7edf3463bc868fb9449cc54ed40ba4e7cae4/gen-secret-name.py)
  - 인자로 repo url을 넣어줄 것(아래 예시)
```
python3 gen-secret-name.py https://gitlab.gitlab-system.172.21.5.210.nip.io/root/argocd-installer.git
```
- data 내 insecure, project, type은 고정이므로 그대로 사용할 것
- url, username, password, tlsClientCertKey는 각각 base64로 인코딩된 값을 넣어줄 것
  - 인코딩 시, url에 ".git" suffix 꼭 붙여주기
  - 아래 참고
```
echo -n 'https://gitlab.example.com/my-org/argocd-installer.git'| base64
```
## 위에서 만든 manifest로 Repo secret 생성할 것
```
kubectl apply -f {repo-secret 파일명}
```
