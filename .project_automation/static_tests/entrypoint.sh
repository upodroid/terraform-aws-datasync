#!/bin/bash

## WARNING: DO NOT modify the content of entrypoint.sh
# Use ./config/static_tests/pre-entrypoint-helpers.sh or ./config/static_tests/post-entrypoint-helpers.sh 
# to load any customizations or additional configurations

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

#********** helper functions *************
pre_entrypoint() {
    if [ -f ${PROJECT_PATH}/.config/static_tests/pre-entrypoint-helpers.sh ]; then
        echo "Pre-entrypoint helper found"
        source ${PROJECT_PATH}/.config/static_tests/pre-entrypoint-helpers.sh
        echo "Pre-entrypoint helper loaded"
    else
        echo "Pre-entrypoint helper not found - skipped"
    fi
}
post_entrypoint() {
    if [ -f ${PROJECT_PATH}/.config/static_tests/post-entrypoint-helpers.sh ]; then
        echo "Post-entrypoint helper found"
        source ${PROJECT_PATH}/.config/static_tests/post-entrypoint-helpers.sh        
        echo "Post-entrypoint helper loaded"
    else
        echo "Post-entrypoint helper not found - skipped"
    fi
}

#********** Pre-entrypoint helper *************
pre_entrypoint

#********** Static Test *************
/bin/bash ${PROJECT_PATH}/.project_automation/static_tests/static_tests.sh
if [ $? -eq 0 ]
then
    echo "Static test completed"
    EXIT_CODE=0
else
    echo "Static test failed"
    EXIT_CODE=1
fi

#********** Post-entrypoint helper *************
post_entrypoint

#********** Markdown Lint **************
echo 'Starting markdown lint'
MYMDL=$(mdl --config ${PROJECT_PATH}/.config/.mdlrc .header.md examples/*/.header.md || true)
if [ -z "$MYMDL" ]
then
    echo "Success - markdown lint found no linting issues!"
else
    echo "Failure - markdown lint found linting issues!"
    echo "$MYMDL"
    exit 1
fi
#********** Terraform Docs *************
echo 'Starting terraform-docs'
TDOCS="$(terraform-docs --config ${PROJECT_PATH}/.config/.terraform-docs.yaml --lockfile=false ./ --recursive)"

# Process examples directories individually
for example_dir in examples/*/; do
  if [ -d "$example_dir" ] && [ -f "${example_dir}main.tf" ]; then
    echo "Processing terraform-docs for $example_dir"
    terraform-docs --config ${PROJECT_PATH}/.config/.terraform-docs.yaml --lockfile=false "$example_dir"
  fi
done

git add -N README.md examples/*/README.md
GDIFF="$(git diff --compact-summary)"
if [ -z "$GDIFF" ]
then
    echo "Success - Terraform Docs creation verified!"
else
    echo "Failure - Terraform Docs creation failed, ensure you have precommit installed and running before submitting the Pull Request. TIPS: false error may occur if you have unstaged files in your repo"
    echo "$GDIFF"
    exit 1
fi
#***************************************
echo "End of Static Tests"
