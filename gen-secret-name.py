# prequsite : pip3 install fnvhash
# run : python3 gen-secret-name.py
from fnvhash import fnv1a_32

def hash_url(url): 
    h = fnv1a_32(url)
    return h

repoURL = b"https://gitlab.gitlab-system.172.21.5.210.nip.io/root/argocd-installer.git"
hashCode = hash_url(repoURL)

hash_str = str(hashCode)
secretNamePrefix = "repo-"
print(secretNamePrefix + hash_str)
