FROM fpco/stack-build:lts-13.27

WORKDIR /app/

COPY stack.yaml /app
COPY package.yaml /app
RUN stack setup && \
    stack exec -- ghc --version
RUN stack build --only-dependencies

# Build project.
COPY . /app
RUN stack build --copy-bins --local-bin-path /usr/local/bin

CMD /usr/local/bin/polysemy-servant

EXPOSE 8081
