package main

import (
	"bufio"
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"runtime"
	"strings"

	"path/filepath"

	"github.com/ProtonMail/go-appdir"
	"gopkg.in/yaml.v2"
)

// The following variables values should normally
// be injected at compile-time. See make.go for more information
var (
	cliWindowsInstallURL = "https://dawn.sh/install-win"
	cliOthersInstallURL  = "https://dawn.sh/install"
	cliDocsURL           = "https://dawn.sh/docs"

	cliConfigurationFolder   = "dawn"
	cliConfigurationFilename = "dawn.yml"

	cliName    = "dawn"
	cliVersion = "development"

	cliDefaultImageName    = "wizcorp/dawn"
	cliDefaultImageVersion = "development"
	cliShellUser           = "dawn"
	cliRootFolder          = "/dawn"

	cliCommitHash  = "n/a"
	cliBuildTime   = "n/a"
	cliBuildServer = "n/a"
)

// In this directory, we will be storing local project data, such as
// the shell history, ssh keys, and so on. This is also where any
// global configuration should go in the future.
var cliAppDirs = appdir.New(cliName)

// Config is the final configuration which will be used
// do determine the project name, and which docker
// image to use
type Config struct {
	ProjectName string
	Image       string
}

// FileConfig is a struct where the content of
// ./[cliConfigurationFolder]/[cliConfigurationFilename] will be loaded locally
type FileConfig struct {
	ProjectName  string           `yaml:"project_name"`
	Image        string           `yaml:"image"`
	Environments FileEnvironments `yaml:"environments,omitempty"`
}

// FileEnvironments is a list of environment-specific
// configurations optionally listed in
// ./[cliConfigurationFolder]/[cliConfigurationFilename]
type FileEnvironments map[string]FileEnvironmentConfig

// FileEnvironmentConfig is a set of custom configuration to
// apply to the global environment
type FileEnvironmentConfig struct {
	Image string `yaml:"image"`
}

// Used by readLine
var reader = bufio.NewReader(os.Stdin)

func readLine() string {
	var stripCount int
	line, _ := reader.ReadString('\n')

	switch runtime.GOOS {
	case "windows":
		stripCount = 2 // strip \r\n
	default:
		stripCount = 1 // strip \n
	}

	return line[:len(line)-stripCount]
}

func printHelp() {
	fmt.Println()
	fmt.Printf("%s starts a pre-configured docker container on your local machine,\n", cliName)
	fmt.Println("from which you can set up and manage your deployments.")
	fmt.Println()
	fmt.Printf("Usage: %s [environment] [command]\n", cliName)
	fmt.Println()
	fmt.Println("    environment    The environment you wish to set up for")
	fmt.Println("    command        Command you wish to run (or run bash if omitted)")
	fmt.Println()
	fmt.Println("Flags")
	fmt.Println()
	fmt.Println("    --update       Update this binary")
	fmt.Println("    --version      Show version information")
	fmt.Println("    --help         Show this screen")
	fmt.Println()
	fmt.Printf("For more information: %s\n", cliDocsURL)
	fmt.Println()
}

func printVersion() {
	fmt.Printf("Platform:      %s\n", runtime.GOOS)
	fmt.Printf("Version:       %s\n", cliVersion)
	fmt.Printf("Commit hash:   %s\n", cliCommitHash)
	fmt.Printf("Built using:   %s\n", runtime.Version())
	fmt.Printf("Build date:    %s\n", cliBuildTime)
	fmt.Printf("Build server:  %s\n", cliBuildServer)
}

func runSubProcess(command string, arguments []string) error {
	cmd := exec.Command(command, arguments...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()

	if err != nil {
		fmt.Printf("%#v", err)
	}

	return err
}

func ensureDirectoryExists(dir string) (string, error) {
	err := os.MkdirAll(dir, 0700)
	return dir, err
}

func getWorkingDirectory() string {
	wd, err := os.Getwd()
	if err != nil {
		panic(err)
	}

	return wd
}

func getLocalDirectory() string {
	return cliAppDirs.UserConfig()
}

func getLocalProjectsDirectory() (string, error) {
	dir := fmt.Sprintf("%s/projects", getLocalDirectory())
	return ensureDirectoryExists(dir)
}

func getLocalProjectDirectory(project string) (string, error) {
	projectsDir, err := getLocalProjectsDirectory()
	if err != nil {
		return "", err
	}

	dir := fmt.Sprintf("%s/%s", projectsDir, project)
	return ensureDirectoryExists(dir)
}

func getLocalProjectEnvironmentDirectory(project string, environment string) (string, error) {
	projectDir, err := getLocalProjectDirectory(project)
	if err != nil {
		return "", err
	}

	dir := fmt.Sprintf("%s/%s", projectDir, environment)
	return ensureDirectoryExists(dir)
}

func findConfigurationFolder(path string) (string, error) {
	cfgPath := fmt.Sprintf("%s/%s", path, cliConfigurationFolder)
	src, err := os.Stat(cfgPath)

	if err != nil || !src.IsDir() {
		parent := filepath.Dir(path)

		// If we reached the top
		if parent == path {
			return "", errors.New("Could not find configuration folder in folder tree")
		}

		return findConfigurationFolder(parent)
	}

	return path, nil
}

func getProjectRoot() string {
	cwd := getWorkingDirectory()
	path, err := findConfigurationFolder(cwd)

	if err != nil {
		return cwd
	}

	return path
}

func getConfigurationFolderPath() string {
	return fmt.Sprintf("%s/%s", getProjectRoot(), cliConfigurationFolder)
}

func getConfigurationFilePath() string {
	return fmt.Sprintf("%s/%s", getConfigurationFolderPath(), cliConfigurationFilename)
}

func getFullImageName(image string) string {
	if strings.Index(image, ":") == -1 {
		return fmt.Sprintf("%s:%s", cliDefaultImageName, image)
	}

	return image
}

func doesConfigurationFileExist() bool {
	_, err := os.Lstat(getConfigurationFilePath())
	if err != nil {
		return false
	}

	return true
}

func createConfigurationFile(projectName string) error {
	err := os.MkdirAll(cliConfigurationFolder, 0700)
	if err != nil {
		return err
	}

	content := fmt.Sprintf("project_name: %s\nimage: %s", projectName, cliDefaultImageVersion)
	err = ioutil.WriteFile(getConfigurationFilePath(), []byte(content), 0644)

	return err
}

func requestConfigurationFileCreation() bool {
	fmt.Printf("This project is not configured yet to use %s. Would you like to configure it? [y/n]: ", cliName)
	answer := readLine()
	if answer != fmt.Sprintf("y") {
		return false
	}

	wd := getWorkingDirectory()
	folderName := filepath.Base(wd)

	fmt.Printf("What is the name of this project [%s]: ", folderName)
	projectName := readLine()
	if projectName == "" {
		projectName = folderName
	}

	err := createConfigurationFile(projectName)
	if err != nil {
		fmt.Printf("Failed to create configuration: %#v", err)
		return false
	}

	return true
}

func getFileConfiguration() (*FileConfig, error) {
	var fileConfig FileConfig
	configPath := getConfigurationFilePath()

	data, err := ioutil.ReadFile(configPath)
	if err != nil {
		return nil, err
	}

	err = yaml.Unmarshal(data, &fileConfig)
	if err != nil {
		return nil, err
	}

	return &fileConfig, nil
}

func getConfigurationForEnvironment(environment string) (*Config, error) {
	var image string
	fileConfig, err := getFileConfiguration()

	if err != nil {
		return nil, err
	}

	if environmentConfiguration, ok := fileConfig.Environments[environment]; ok {
		image = environmentConfiguration.Image
	} else {
		image = fileConfig.Image
	}

	return &Config{
		fileConfig.ProjectName,
		image,
	}, nil
}

func runUpdate() error {
	var shell string
	var url string
	var arguments []string

	switch runtime.GOOS {
	case "windows":
		url = cliWindowsInstallURL
		shell = "powershell"
		arguments = []string{
			"-Command",
			fmt.Sprintf("Invoke-RestMethod %s/install-windows | powershell -command -", url),
		}
	default:
		url = cliOthersInstallURL
		shell = "bash"
		arguments = []string{
			"-c",
			fmt.Sprintf("curl -fsSL %s/install | sh", url),
		}
	}

	return runSubProcess(shell, arguments)
}

func runEnvironmentContainer(environment string, configuration *Config, command []string) error {
	localEnvironmentDir, err := getLocalProjectEnvironmentDirectory(configuration.ProjectName, environment)
	if err != nil {
		return err
	}

	arguments := []string{
		"run",
		"--rm",
		"-it",
		"-e", fmt.Sprintf("PROJECT_ENVIRONMENT=%s", environment),
		"-e", fmt.Sprintf("PROJECT_NAME=%s", configuration.ProjectName),
		"-v", fmt.Sprintf("%s:%s/project", getProjectRoot(), cliRootFolder),
		"-v", fmt.Sprintf("%s:/home/%s", localEnvironmentDir, cliShellUser),
	}

	// During development, it is possible to mount directly the local
	// files which normally are already baked into the container
	development := os.Getenv("DEVELOPMENT_MODE")
	if development != "" {
		fmt.Println("************************************************************************")
		fmt.Printf("WARNING: Running in develop mode! (using: %s)\n", development)
		fmt.Println("************************************************************************")

		arguments = append(arguments, "-v")
		arguments = append(arguments, fmt.Sprintf("%s/docker-image/scripts:%s/scripts", development, cliRootFolder))
		arguments = append(arguments, "-v")
		arguments = append(arguments, fmt.Sprintf("%s/docker-image/ansible:%s/ansible", development, cliRootFolder))
		arguments = append(arguments, "-v")
		arguments = append(arguments, fmt.Sprintf("%s/docker-image/templates:%s/templates", development, cliRootFolder))
	}

	arguments = append(arguments, getFullImageName(configuration.Image))

	return runSubProcess("docker", append(arguments, command...))
}

func main() {
	var err error

	if len(os.Args) < 2 {
		printHelp()
		return
	}

	args := os.Args[1:]
	switch args[0] {
	case "--help":
		printHelp()
	case "--version":
		printVersion()
	case "--update":
		err = runUpdate()
	default:
		// Make sure the configuration folder and file exists
		if doesConfigurationFileExist() == false {
			created := requestConfigurationFileCreation()
			if !created {
				break
			}
		}

		// Get the environment name; optionally,
		// the user may pass a custom command (just like
		// when using plain docker)
		environment := args[0]
		command := args[1:]

		// This will load the global configuration and
		// apply any environment-specific overrides to it
		configuration, err := getConfigurationForEnvironment(environment)
		if err != nil {
			panic(err)
		}

		// Run the container
		err = runEnvironmentContainer(environment, configuration, command)
	}

	if err != nil {
		os.Exit(1)
	}
}
