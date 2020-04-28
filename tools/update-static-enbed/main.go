package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"github.com/google/go-github/github"
)

var params struct {
	root   string
	output string

	githubUser  string
	githubToken string
}

func newGitHubClient() *github.Client {
	if len(params.githubUser) == 0 {
		return github.NewClient(nil)
	}
	http := http.Client{
		Transport: &github.BasicAuthTransport{
			Username: params.githubUser,
			Password: params.githubToken,
		},
	}
	return github.NewClient(&http)
}

func validate() error {
	if len(params.root) == 0 {
		return errors.New("-root not set")
	}
	if len(params.output) == 0 {
		return errors.New("-output not set")
	}
	return nil
}

func getSources() ([]string, error) {
	sources := make(map[string]struct{})
	err := filepath.Walk(params.root, func(path string, info os.FileInfo, err error) error {
		if info.Name() != "index.md" && info.Name() != "index.html.md" {
			return nil
		}

		f, err := os.Open(path)
		if err != nil {
			return err
		}
		defer f.Close()

		ss, err := ScanGithub(path, f)
		if err != nil {
			return err
		}
		for k := range ss {
			sources[k] = struct{}{}
		}
		return nil

	})
	if err != nil {
		return nil, err
	}
	var slice []string
	for k := range sources {
		slice = append(slice, k)
	}
	return slice, nil
}

func run(ctx context.Context) error {
	sources, err := getSources()
	if err != nil {
		return err
	}
	log.Printf("Updating %d repositories", len(sources))

	data := make(map[string]Data)
	g := newGitHubClient()
	for _, src := range sources {
		s := strings.Split(src, "/")
		if len(s) != 2 {
			return errors.New("invalid github source: " + src)
		}
		repo, _, err := g.Repositories.Get(ctx, s[0], s[1])
		if err != nil {
			return err
		}
		log.Printf("Got repository: %s", src)

		data[src] = Data{
			AvatarURL:   repo.Owner.GetAvatarURL(),
			URL:         repo.GetHTMLURL(),
			Description: repo.GetDescription(),
		}
	}
	err = WriteData(params.output, data)
	if err != nil {
		return err
	}
	log.Printf("Wrote to %s", params.output)
	return nil
}

func main() {
	flag.StringVar(&params.root, "root", "", "root directory to scan")
	flag.StringVar(&params.output, "output", "", "output json file")
	flag.Parse()

	params.githubUser = os.Getenv("GITHUB_USER")
	params.githubToken = os.Getenv("GITHUB_TOKEN")

	err := validate()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	err = run(context.Background())
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
