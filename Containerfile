FROM fedora:40

RUN yum -y install varnish varnish-modules
CMD ["varnishd", "-F", "-f", "/etc/varnish/default.vcl"]
