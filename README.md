# signing-container-images

1. First create a gpg key for the user and then list if is properly created and listed.
```bash
gpg --full-gen-key
gpg --list-keys
```
2. Then export the gpg key to a file. In place of `kay@example.com` you have to provide the owner name which you given while creating the key.
```bash
mkdir /root/signing-container-images;cd signing-container-images
gpg --output ./mykey.gpg --armor --export kay@example.com
cat ./mykey.gpg
```
3. Now build the image
```bash
git clone https://github.com/kaybee-singh/signing-container-images /root/signing-container-images
cd /root/signing-container-images
podman build -t webs:1 -f containerfile .
```
4. Tag and push to the registry
```bash
podman tag localhost/webs:1 quay-all.example.com/quayuser/a/webs:1
podman push quay-all.example.com/quayuser/a/webs:1 --tls-verify=false
```
4. Configure web server

```bash
yum install httpd -y
sed -i 's/^Listen 80$/Listen 90/' /etc/httpd/conf/httpd.conf
systemctl enable httpd --now
firewall-cmd --add-port 90/tcp --permanent
firewall-cmd --reload
setenforc 0
```
4. Copy the signature directory to webserver document root.
```bash
cp -R /var/lib/containers/sigstore/quayuser /var/www/html
ls -l /var/www/html/
total 3
drwxr-xr-x 3 root root  15 Aug 30 08:35 quayuser
```

5. On the system where you want to pull the images modify default.yaml or create a different yaml file for your registry.
```bash
# cat /etc/containers/registries.d/default.yaml
docker:
    quay-all.example.com:
      sigstore: http://10.74.232.187:90
```

6. Configure the policy.json
```bash
# cat /etc/containers/policy.json 
{
  "default": [
    {
      "type": "reject"
    }
  ],
  "transports": {
    "docker": {
      "quay-all.example.com": [
        {
          "type": "signedBy",
	  "keyType": "GPGKeys",
          "keyPath": "/etc/pki/kay-pub.asc"
        }
      ]
    }
  }
}
```
7. Copy the GPG public key to the above specified `keyPath`
```bash
gpg --export kay@example.com > kay-pub.asc
cp kay-pub.asc /etc/pki/kay-pub.asc
```
