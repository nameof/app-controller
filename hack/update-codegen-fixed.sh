#!/usr/bin/env bash

# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")/..
CODEGEN_PKG=${CODEGEN_PKG:-$(cd "${SCRIPT_ROOT}"; ls -d -1 ./vendor/k8s.io/code-generator 2>/dev/null || echo ../code-generator)}

# Pre-requisites
# 1. this script needs ./pkg/apis/appcontroller/v1alpha1 to generate everything else (generated files will be empty otherwise)
# 2. changing --output-base to something else doesn't work
#
# Only the following things can be auto-generated:
# 1. ./pkg/apis/appcontroller/v1alpha1/zz_generated.deepcopy.go
# 2. everything under ./pkg/apis/generated
bash "${CODEGEN_PKG}"/generate-groups.sh "deepcopy,client,informer,lister" \
  k8s.io/sample-controller/pkg/generated k8s.io/sample-controller/pkg/apis \
  samplecontroller:v1alpha1 \
  --output-base "$(dirname "${BASH_SOURCE[0]}")/../../.." \
  --go-header-file "${SCRIPT_ROOT}"/hack/boilerplate.go.txt

# This block:
# output_base: the directory outside the repo where auto-generated files are created
# 1. removes existing auto-generated files
# 2. copies over the auto-generated files from the output_base to pkg/apis and pkg/generated
# 3. removes output_base
rm -R ./pkg/apis/samplecontroller/v1alpha1/zz_generated.deepcopy.go ./pkg/generated -f
mv "$(dirname "${BASH_SOURCE[0]}")/../../../k8s.io/sample-controller/pkg/apis/samplecontroller/v1alpha1/zz_generated.deepcopy.go" $SCRIPT_ROOT/pkg/apis/samplecontroller/v1alpha1 -f
mv "$(dirname "${BASH_SOURCE[0]}")/../../../k8s.io/sample-controller/pkg/generated" $SCRIPT_ROOT/pkg
rm -R "$(dirname "${BASH_SOURCE[0]}")/../../../k8s.io"

# To use your own boilerplate text append:
#   --go-header-file "${SCRIPT_ROOT}"/hack/custom-boilerplate.go.txt
