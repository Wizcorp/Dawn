package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"runtime"
	"strings"

	"path"

	"github.com/ProtonMail/go-appdir"
	"gopkg.in/yaml.v2"
)

// The following variables values should normally
// be injected at compile-time
var dawnURL = "https://dawn.sh"
var dawnDefaultImage = "development"
var dawnVersion = "development"
var dawnCommitHash = "n/a"
var dawnBuildTime = "n/a"
var dawnBuildServer = "n/a"

// In this directory, we will be storing local project data, such as
// the shell history, ssh keys, and so on. This is also where any
// global configuration for dawn should go in the future.
var dawnAppDirs = appdir.New("dawn")

// Config is the final configuration which will be used
// by Dawn do determine the project name, and which docker
// image to use
type Config struct {
	ProjectName string
	Image       string
}

// FileConfig is a struct where the content of
// ./dawn/dawn.yml will be loaded locally
type FileConfig struct {
	ProjectName  string           `yaml:"project_name"`
	Image        string           `yaml:"image"`
	Environments FileEnvironments `yaml:"environments,omitempty"`
}

// FileEnvironments is a list of environment-specific
// configurations optionally listed in ./dawn/dawn.yml
type FileEnvironments map[string]FileEnvironmentConfig

// FileEnvironmentConfig is a set of custom configuration to
// apply to the global environment
type FileEnvironmentConfig struct {
	Image string `yaml:"image"`
}

func printHelp() {
	fmt.Println()
	fmt.Println("dawn starts a pre-configured docker container on your local machine,")
	fmt.Println("from which you can set up and manage your deployments.")
	fmt.Println()
	fmt.Println("Usage: dawn [environment] [command]")
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
	fmt.Println("For more information: https://dawn.sh/docs")
	fmt.Println()
}

func printVersion() {
	fmt.Printf("Platform:      %s\n", runtime.GOOS)
	fmt.Printf("Version:       %s\n", dawnVersion)
	fmt.Printf("Commit hash:   %s\n", dawnCommitHash)
	fmt.Printf("Built using:   %s\n", runtime.Version())
	fmt.Printf("Build date:    %s\n", dawnBuildTime)
	fmt.Printf("Build server:  %s\n", dawnBuildServer)
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

func getDawnLocalDirectory() string {
	return dawnAppDirs.UserConfig()
}

func getDawnLocalProjectsDirectory() (string, error) {
	dir := fmt.Sprintf("%s/projects", getDawnLocalDirectory())
	return ensureDirectoryExists(dir)
}

func getLocalProjectDirectory(project string) (string, error) {
	projectsDir, err := getDawnLocalProjectsDirectory()
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

func getDawnFolderPath() string {
	return fmt.Sprintf("%s/%s", getWorkingDirectory(), "dawn")
}

func getConfigurationFilePath() string {
	return fmt.Sprintf("%s/%s", getDawnFolderPath(), "dawn.yml")
}

func getFullImageName(image string) string {
	if strings.Index(image, ":") == -1 {
		return fmt.Sprintf("dawn:%s", image)
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
	err := os.MkdirAll(getDawnFolderPath(), 0700)
	if err != nil {
		return err
	}

	content := fmt.Sprintf("project_name: %s\nimage: %s", projectName, dawnDefaultImage)
	err = ioutil.WriteFile(getConfigurationFilePath(), []byte(content), 0644)

	return err
}

func requestConfigurationFileCreation() bool {
	fmt.Print("This project is not configured yet to use dawn. Would you like to configure it? [y/n]: ")
	reader := bufio.NewReader(os.Stdin)
	answer, _ := reader.ReadString('\n')

	if answer != "y\n" {
		return false
	}

	wd, err := os.Getwd()
	folderName := path.Base(wd)

	fmt.Printf("What is the name of this project [%s]: ", folderName)
	answer, _ = reader.ReadString('\n')
	projectName := answer[:len(answer)-1]

	if projectName == "" {
		projectName = folderName
	}

	err = createConfigurationFile(projectName)
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
		url = dawnURL + "/install-windows"
		shell = "powershell"
		arguments = []string{
			"-Command",
			fmt.Sprintf("Invoke-RestMethod %s/install-windows | powershell -command -", url),
		}
	default:
		url = dawnURL + "/install"
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
		"-e", fmt.Sprintf("DAWN_ENVIRONMENT=%s", environment),
		"-e", fmt.Sprintf("DAWN_PROJECT_NAME=%s", configuration.ProjectName),
		"-v", fmt.Sprintf("%s:/dawn/project", getWorkingDirectory()),
		"-v", fmt.Sprintf("%s:/root", localEnvironmentDir),
		"-it",
		getFullImageName(configuration.Image),
	}

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
		// Make sure ./dawn and ./dawn/dawn.yml exist
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

		// Run the dawn container
		err = runEnvironmentContainer(environment, configuration, command)
	}

	if err != nil {
		os.Exit(1)
	}
}
