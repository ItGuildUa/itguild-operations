#!/usr/bin/env bash

which git    >/dev/null || echo "git is missing"
which docker >/dev/null || echo "docker is missing"

TF_HOOKS_VERSION=v1.62.3

function install_tf_hooks() {
    mkdir -p tools-build
    cd tools-build
    git clone https://github.com/antonbabenko/pre-commit-terraform
    cd pre-commit-terraform
    git checkout "$TF_HOOKS_VERSION"

    docker build -t "pre-commit-terraform:$TF_HOOKS_VERSION" \
    --build-arg PRE_COMMIT_VERSION=latest \
    --build-arg TERRAFORM_VERSION=latest \
    --build-arg CHECKOV_VERSION=2.0.405 \
    --build-arg INFRACOST_VERSION=latest \
    --build-arg TERRAFORM_DOCS_VERSION=0.15.0 \
    --build-arg TERRAGRUNT_VERSION=latest \
    --build-arg TERRASCAN_VERSION=1.10.0 \
    --build-arg TFLINT_VERSION=0.31.0 \
    --build-arg TFSEC_VERSION=latest \
        .

    cd ../..
}

which docker && docker images | grep tf-pre-commit || install_tf_hooks
