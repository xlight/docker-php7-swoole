# docker-php7-swoole

# Usage 

    docker run -d --name=some-swoole -v /workdir:/workdir -p 9501:9501 \
      php /workdir/app_server.php start
    

* this container has no php code or framework included
* php extension installed: GD mcrypt iconv memcached pdo_mysql dom xml curl swoole
