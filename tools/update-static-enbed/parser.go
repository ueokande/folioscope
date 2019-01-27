package main

import (
	"errors"
	"regexp"
)

var tagRegex = regexp.MustCompile(`{{\s*<\s*([a-z-_]+)\s*(.*)>\s*}}`)
var attrRegex = regexp.MustCompile(`([a-z]+)="([^"]*)"`)

type Shortcode struct {
	Tag   string
	Attrs map[string]string
}

func ParseShortcode(line string) (*Shortcode, error) {
	match := tagRegex.FindStringSubmatch(line)
	if len(match) == 0 {
		return nil, errors.New("not match")
	}
	tag := match[1]
	attrLine := match[2]

	matches := attrRegex.FindAllStringSubmatch(attrLine, -1)
	attrs := make(map[string]string)
	for _, match := range matches {
		attrs[match[1]] = match[2]
	}
	return &Shortcode{Tag: tag, Attrs: attrs}, nil
}
