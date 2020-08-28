# How to use this image

## Start a presentation

```sh
docker run -d -p 3999:3999 -v /path/to/your/slides:/talk cremuzzi/go-present
```

where `/path/to/your/slides` is the path on your host with the '.slide' files you want to present.

then open your browser and visit http://127.0.0.1:3999
