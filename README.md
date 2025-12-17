# TYPO3 Base Prod Container for PHP 8.2

This container provides a TYPO3 base environment built on PHP-FPM 8.2 and includes all required components to run a standard TYPO3 installation.

The image is built using a multi-stage build to keep the container as lean, performant, and maintainable as possible. It is based on Alpine Linux, resulting in a hardened and resource-efficient container. In addition, the container is rootless and distroless, further reducing the attack surface and improving overall security.

To ensure better C compilation and interpretation, gcc is installed during the build process. This intentionally avoids relying on Alpine’s default libraries and improves performance and compatibility, especially for PHP extensions and other native dependencies.

For project-specific usage, developers are expected to provide their own Dockerfile and copy their application code into the container accordingly.
```dockerfile
FROM <YOUR_IMAGE_TAG_NAME>

COPY <YOUR_PROJECT_ROOT>/ .
RUN chown -R www-data:www-data /usr/share/nginx/html/

USER www-data
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
```
Certain directories should not be copied directly into the container, as they are intended to be mounted later via volumes or bind mounts. This approach ensures data persistence, flexibility, and a clean separation between application code and runtime data.
```apacheconf
public/fileadmin
public/typo3temp
var/
tests
<packages/extensions>/ext-*/Tests
```


## License
This container image is provided as-is, without any warranties or guarantees of any kind.
It may be used, modified, and extended for private and commercial purposes.

Redistribution of modified or unmodified versions is permitted, provided that this notice remains included and the original authorship is clearly acknowledged.

The authors shall not be held liable for any damages, data loss, or security issues arising from the use of this container image.

## About us

MCEikens is a technology-focused company specializing in modern web solutions, containerized infrastructures, and scalable application architectures. With a strong emphasis on performance, security, and maintainability, we design and build robust systems tailored to real-world production requirements.

Our work combines practical engineering expertise with a clear focus on clean, efficient, and future-proof solutions. From containerized TYPO3 environments to custom DevOps workflows, MCEikens delivers reliable foundations for sustainable digital platforms.

### Contact
E-Mail: dialog@mceikens.de