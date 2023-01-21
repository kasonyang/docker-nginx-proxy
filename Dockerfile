FROM nginx:1.23.3
EXPOSE 80
# For SSL certificate
RUN curl -L https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh | sh -s -- --install-online --force
RUN mkdir /np-app/
COPY np-app/ /np-app/
RUN chmod +x /np-app/tpl-gen
RUN chmod +x /np-app/run-on-change
CMD ["bash", "/np-app/start.sh"]