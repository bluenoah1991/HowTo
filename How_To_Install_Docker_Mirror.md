# Install Docker

    sudo wget -qO- https://get.docker.com/ | sh  

# Install Docker Compose  

    sudo pip install docker-compose  

# Create Store Directory  

    mkdir -p /opt/data/registry  
    mkdir -p /opt/data/redis  

# Write a docker-compose.yml  

    # This compose file will start 2 containers: registry and redis.  
    # registry container will listen on host port 5000,  
    # and depend on the redis container as the cache scheme.  
      
      
    registry:  
        image: registry:latest  
        cpu_shares: 10  
        environment:  
            - STANDALONE=false  
            - MIRROR_SOURCE=https://registry-1.docker.io  
            - MIRROR_SOURCE_INDEX=https://index.docker.io  
            - CACHE_REDIS_HOST=redis  
            - CACHE_REDIS_PORT=6379  
            - DEBUG=false  
        hostname: docker-registry  
        links:  
            - redis:redis  
        mem_limit: 512m  
        ports:  
            - "5000:5000"  
        privileged: false  
        restart: always  
        user: root  
        volumes:  
            - /opt/data/registry:/tmp/registry  
      
    redis:  
        image: redis:3.0  
        cpu_shares: 10  
        expose:  
            - "6379"  
        mem_limit: 512m  
        restart: always  
        volumes:  
            - /opt/data/redis:/data  

# Run Mirror Service  

    docker-compose up -d  

# Client modify '/etc/default/docker'  

    DOCKER_OPTS="$DOCKER_OPTS --registry-mirror http://localmirror:5000"  


