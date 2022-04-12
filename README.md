## Run as container

```
To build this image:
-Open cmd or powershell with Docker running
-cd %directory of the dockerfile%
-Then run the command: "docker build -t forcoast-sm-f1 ."

Available parameters: (parameters are area dependent, defaults: black sea)

$1: Weight bathymetry, default: 0.33
$2: Weight salinity, default:0.55
$3: Weight temperature, default: 0.12
$4: Geoserver username
$5: Geoserver password

To run the container:

"docker run forcoast-sm-f1 $1 $2 $3 $4 $5" all parameters need to be given
Example with default values: "docker run forcoast-sm-f1 0.33 0.55 0.12 admin #33f0rc0ast"
```

## Coastal Application Package

### Register Coastal Application Package


```
curl -X POST \
	-H "Accept: application/json"  \
	-H "Content-Type: application/json" \
	-d @coastal-application-package.json \
	https://wps.forcoast.apps.k.terrasigna.com/rest/processes
```

### Run application

```
curl -X POST \
	-H "Accept: application/json" \
	-H "Content-Type: application/json" \
	-d @coastal-run1.json \
	https://wps.forcoast.apps.k.terrasigna.com/rest/processes/terrasigna-coastal-ap/jobs
```

#test
