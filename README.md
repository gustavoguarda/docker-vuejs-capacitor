# App Vuejs with capacitor 

### Build image
```
docker build -t vuejs-capacitor .
```

### Run image
```
docker run -it -v $(pwd):/app vuejs-capacitor
```

or

```
docker run -it -v $(pwd):/app --entrypoint "/bin/bash" vuejs-capacitor -c 'su $(stat -c "%U" $(pwd)) -s /bin/bash'

```

### Run build script (capacitor)
```
./build.sh
```