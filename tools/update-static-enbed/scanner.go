package main

import (
	"bufio"
	"fmt"
	"io"
	"strings"
)

type MissingAttrErr struct {
	attr   string
	path   string
	lineno int
}

func (p MissingAttrErr) Error() string {
	return fmt.Sprintf("missing %s: path=%s, lineno=%d", p.attr, p.path, p.lineno)
}

func ScanGithub(name string, r io.Reader) (map[string]struct{}, error) {
	sources := make(map[string]struct{})

	s := bufio.NewScanner(r)
	for lineno := 1; s.Scan(); lineno++ {
		line := strings.TrimSpace(s.Text())
		sc, err := ParseShortcode(line)
		if err != nil {
			continue
		}
		if sc.Tag != "github" {
			continue
		}
		src := sc.Attrs["src"]
		if len(src) == 0 {
			return nil, MissingAttrErr{
				attr:   "src",
				path:   name,
				lineno: lineno,
			}
		}
		sources[src] = struct{}{}
	}
	if err := s.Err(); err != nil {
		return nil, err
	}
	return sources, nil
}
