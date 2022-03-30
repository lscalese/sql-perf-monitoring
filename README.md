## sql-perf-monitoring

This is a sql query performance tool provided by [David Loveluck](https://community.intersystems.com/user/david-loveluck).  
See the related [community article](https://community.intersystems.com/post/apm-%E2%80%93-monitoring-sql-query-performance) for more informations.  


## Docker Installation 

Attention : it's not compatible with community container image.  
Pull or adapt the image base in `Dockerfile`.  
Current image is : `containers.intersystems.com/intersystems/iris:2021.1.0.215.0`  


Clone/git pull the repo into any local directory

```bash
git clone https://github.com/lscalese/sql-perf-monitoring.git
```

Put your iris.key the repo directory.  

Open the terminal in this directory and run:

```bash
docker-compose build
```

3. Run the IRIS container with your project:

```bash
docker-compose up -d
```

## ZPM Installation

Open an IRIS\HealthShare terminal : 

```
zpm "install sql-perf-monitoring"
```