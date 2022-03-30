# 외부 클러스터로 app 배포 가이드
목적 : ArgoCD가 설치된 클러스터 외에 다른 클러스터로 application을 배포하려고 할 때, UI로는 불가하여 ArgoCD CLI를 통해 해야 함

0. argocd가 설치되어 있는 클러스터 config에 타겟 클러스터 config를 병합
1. 배포하려는 타겟 클러스터로 컨텍스트 설정
- kubectl config use-context {{ 클러스터-컨텍스트-이름 }} 또는 
- kubectl config set current-context {{ 클러스터컨텍스트-이름 }} 을 사용하여 컨텍스트 체인지.
2. argocd login {{ 호스트명 }}
- 여기서 호스트명은 argocd 서버 주소. 
3. argocd cluster add {{ 컨텍스트명 }}
- 이 때 배포하려는 클러스터에 argocd manager 서비스어카운트가 자동으로 설치됨
- ClusterRole "argocd-manager-role", ClusterRoleBinding "argocd-manager-role-binding"도 같이 생성
5. ui에서 클러스터 등록되어 있는지 확인
6. application 작성시, Destination 클러스터에, 타겟 클러스터 주소 기입
- 잘 등록이 되어있다면 드롭다운이 뜸
