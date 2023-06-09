import base64
import hashlib
from Crypto.Cipher import AES
from Crypto import Random
from Crypto.Protocol.KDF import PBKDF2

BS = 16
pad = lambda s: bytes(s + (BS - len(s) % BS) * chr(BS - len(s) % BS), 'utf-8')
unpad = lambda s : s[0:-ord(s[-1:])]

password = input("Enter encryption password: ")

def encrypt(raw, password):
    private_key = hashlib.sha256(password.encode("utf-8")).digest()
    raw1 = pad(raw)
    iv = Random.new().read(AES.block_size)
    cipher = AES.new(private_key, AES.MODE_CBC, iv)
    return base64.b64encode(iv + cipher.encrypt(raw1))

def decrypt(enc, password):
    private_key = hashlib.sha256(password.encode("utf-8")).digest()
    enc1 = base64.b64decode(enc)
    iv = enc1[:16]
    cipher = AES.new(private_key, AES.MODE_CBC, iv)
    #enc2 = unpad(enc1)
    #return cipher.decrypt(enc2)
    #return unpad(cipher.decrypt(enc1[16:]))

dbE = open("/home/sabeiro/Pictures/cel/WazupDb/msgstore-2022-05-30.1.db.crypt15","rb").read()
encrypted = encrypt("This is a secret message", password)
print(encrypted)
decrypted = decrypt(encrypted, password)
print(bytes.decode(decrypted))

decrypted = decrypt(dbE, password)
mex = bytes.decode(decrypted)
print(mex[:100])
