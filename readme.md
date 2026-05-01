# clamav-maldet

This [docker container][url_docker] consists of [ClamAV][url_clamav], [Linux Malware Detect][url_maldet] and a simple WebUI.

## Motivation

I'm running [ClamAV][url_clamav] on my [NAS][url_wiki_nas]. The OS is [Open Media Vault (OMV)][url_openmediavault]. Up to now the antivirus program was installed as plugin of [OMV][url_openmediavault]. Then I've dropped a large amount of images there and on the next scan [ClamAV][url_clamav] identified them as virus infected and moved them to quarantine. Unfortunately [ClamAV][url_clamav] does not offer a way to restore files from quarantine to the original location. This is why [Linux Malware Detect][url_maldet] is used, because this antivirus solution uses [ClamAV][url_clamav] as scanner but offers some kind of `restore from quarantine`. To offer a little comfort to the user, the quarantined files are listed and can be moved to the original location.

## The image

To build the container, you can run the following commands. There are some conventions used:

- \<ROC:ROCP\> - `R`egistry `O` your `C`hoice, e. g. 192.168.0.10, as well as `R`egistry `O` your `C`hoice `P`ort, e. g. 5000, full value is 192.168.0.10:5000

```bash
# Build the local image
docker build -t clamav-maldet:latest .

# Tag the local image
docker tag clamav-maldet:latest <ROC:ROCP>/clamav-maldet:latest

# Push the local image to the registry of your choice
docker push <ROC:ROCP>/clamav-maldet:latest

# Check the registry of your choice for the image
curl http://<ROC:ROCP>/v2/_catalog | grep -i clamav-maldet

# The output must contain a clamav-maldet entry
```

[url_clamav]: https://www.clamav.net/
[url_docker]: https://www.docker.com/
[url_maldet]: https://www.rfxn.com/projects/linux-malware-detect/
[url_openmediavault]: https://www.openmediavault.org/
[url_wiki_nas]: https://en.wikipedia.org/wiki/Network-attached_storage
