# embedded-containers


## To build docker images

Command structure:
```shell
docker buildx bake -o, --output=[PATH,-,type=TYPE[,KEY=VALUE]
```
Output must be specified and has to be one of the supported types:

- local
- tar
- oci
- docker
- image
- registry

You can export multiple outputs by repeating the flag.



Locally (will only work for single platform images):
```shell
docker buildx bake ncs --set "*.output=type=image"
docker buildx bake --load #Will load into docker 
```
Push to registry:
```shell
docker buildx bake ncs --set "*.output=type=image"
docker buildx bake --push #Will load into docker 
```

Run the image in docker with:
```shell
docker run --rm -it [TAG | IMAGE_ID]
```

