// +build ignore

/**
 * Inspired by:
 * https://github.com/camlistore/camlistore/blob/master/make.go
 */

package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"runtime"
	"strings"
	"time"

	"flag"

	"github.com/fatih/color"
)

var (
	target  string
	version string
)

func main() {
	runStep("Installing dependencies", install)

	targetPtr := flag.String("target", runtime.GOOS, "Operating system to build for. (windows, linux, darwin or all)")
	versionPtr := flag.String("version", "development", "Version number to attach to this build)")

	flag.Parse()

	target = *targetPtr
	version = *versionPtr

	if target == "all" {
		target = "darwin"
		runStep("Building dawn binary (darwin)", build)

		target = "windows"
		runStep("Building dawn binary (windows)", build)

		target = "linux"
		runStep("Building dawn binary (linux)", build)
	} else {
		runStep("Building dawn binary", build)
	}
}

type Step func()

func runSubProcess(command string, arguments []string) {
	cmd := exec.Command(command, arguments...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	cmd.Env = append(os.Environ(), fmt.Sprintf("GOOS=%s", target))

	err := cmd.Run()

	if err != nil {
		log.Fatalf("Failed to run command: %#v", err)
	}
}

func runStep(description string, step Step) {
	c := color.New(color.BgCyan, color.FgBlack)
	fmt.Println("")
	c.Printf(" make ")
	fmt.Printf(" %s ", description)
	c.Printf(" make ")
	fmt.Println("")

	step()
}

func getCommitHash() string {
	cmd := exec.Command("git", "rev-parse", "--verify", "HEAD")
	output, err := cmd.Output()

	if err != nil {
		log.Fatalf("Failed to retrieve git commit hash: %#v", err)
	}

	return string(output)
}

func install() {
	runSubProcess("glide", []string{
		"install",
	})
}

func build() {
	targetPath := fmt.Sprintf("./dist/%s", target)
	bin := "dawn"

	if target == "windows" {
		bin = "dawn.exe"
	}

	hostname, _ := os.Hostname()
	now := time.Now()
	commitHash := getCommitHash()

	ldFlags := []string{
		fmt.Sprintf("-X main.dawnVersion=%s", version),
		fmt.Sprintf("-X main.dawnCommitHash=%s", commitHash),
		fmt.Sprintf("-X main.dawnBuildTime=%s", now.Format(time.RFC3339)),
		fmt.Sprintf("-X main.dawnBuildServer=%s", hostname),
	}

	os.MkdirAll(targetPath, 0700)

	args := []string{
		"build",
		"-ldflags",
		strings.Join(ldFlags, " "),
		"-o",
		fmt.Sprintf("%s/%s", targetPath, bin),
		"dawn.go",
	}

	runSubProcess("go", args)
}
