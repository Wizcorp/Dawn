$SCRIPT_DIR = Split-Path $myInvocation.MyCommand.Path
$PROJECT_DIR = split-path $SCRIPT_DIR -parent | split-path -parent

. "${PROJECT_DIR}/scripts/buildconfig.ps1"

$binary_name="$(getBuildConfig binary.name)"
$root_folder="$(getBuildConfig image.root_folder)"
$shell_user="$(getBuildConfig image.shell_user)"
$configuration_folder="$(getBuildConfig configuration.folder)"
$configuration_filename="$(getBuildConfig configuration.filename)"
$ansible_version="$(getBuildConfig image.software_versions.ansible)"
$terraform_version="$(getBuildConfig image.software_versions.terraform)"
$docker_version="$(getBuildConfig image.software_versions.docker)"

$organization="$(getBuildConfig image.organization)"
$name="$(getBuildConfig image.name)"
$image_name="${organization}/${name}"

Write-Output "Building image ${image_name}"

docker build `
    "${PROJECT_DIR}/docker-image" `
    --tag "${image_name}" `
    --build-arg binary_name="${binary_name}" `
    --build-arg root_folder="${root_folder}" `
    --build-arg shell_user="${shell_user}" `
    --build-arg configuration_folder="${configuration_folder}" `
    --build-arg configuration_filename="${configuration_filename}" `
    --build-arg ansible_version="${ansible_version}" `
    --build-arg terraform_version="${terraform_version}" `
    --build-arg docker_version="${docker_version}"


docker tag "${image_name}" "${image_name}:development"
