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
