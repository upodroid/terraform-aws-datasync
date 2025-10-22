#!/bin/bash

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

echo "Starting Functional Tests"
cd ${PROJECT_PATH}

#********** Terraform Test **********

# Look up the mandatory test files
EXAMPLE_1_TEST_PATH="./tests/01_efs_to_s3.tftest.hcl"
EXAMPLE_2_TEST_PATH="./tests/02_s3_to_s3.tftest.hcl"
#EXAMPLE_3_TEST_PATH="./tests/03_s3_to_s3_xaccount.tftest.hcl"

if test -f ${EXAMPLE_1_TEST_PATH}; then
    echo "File ${EXAMPLE_1_TEST_PATH} is found, resuming test"
else
    echo "File ${EXAMPLE_1_TEST_PATH} not found. You must include at least one test run in file ${EXAMPLE_1_TEST_PATH}"
    (exit 1)
fi 

if test -f ${EXAMPLE_2_TEST_PATH}; then
    echo "File ${EXAMPLE_2_TEST_PATH} is found, resuming test"
else
    echo "File ${EXAMPLE_2_TEST_PATH} not found. You must include at least one test run in file ${EXAMPLE_2_TEST_PATH}"
    (exit 1)
fi 

# if test -f ${EXAMPLE_3_TEST_PATH}; then
#     echo "File ${EXAMPLE_3_TEST_PATH} is found, resuming test"
# else
#     echo "File ${EXAMPLE_3_TEST_PATH} not found. You must include at least one test run in file ${EXAMPLE_3_TEST_PATH}"
#     (exit 1)
# fi 

# Run Terraform test
terraform init
terraform test

if [ $? -eq 0 ]; then
    echo "Terraform Test Successfull"
else
    echo "Terraform Test Failed"
    exit 1
fi

echo "End of Functional Tests"