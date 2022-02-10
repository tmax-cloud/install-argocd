# prequsite : pip3 install fnvhash
# run : python3 gen-secret-name.py
from fnvhash import fnv1a_32
import sys

def hash_url(url): 
    h = fnv1a_32(url)
    return h

arg = sys.argv

repoURL = bytes(arg[1], 'utf-8')
hashCode = hash_url(repoURL)

hash_str = str(hashCode)
secretNamePrefix = "repo-"
print(secretNamePrefix + hash_str)
